from __future__ import print_function, division
import pygame, time, threading, sys, math, serial, random, struct
import socket, csv, os, os.path
from pygame.locals import *

# Note: Runs on python 2.7. Required Libraries:
# pyserial
# pygame

MIN_VALUE = 0
MAX_VALUE = 1024
USE_SERIAL = True
SINK_MODE = "csv" # Available modes: 'csv', 'bin'
SERIAL_PORT = 12 # Set to port number or None for autodetection
BAUD_RATE = 460800

HUMAN_TIMESTAMPS = True

# Autodetect serial port
if SERIAL_PORT is None:
    for i in range(64):
        try:
            print("Trying port %d..." % i,)
            tport = serial.Serial(i, BAUD_RATE)
            print("Success")
            SERIAL_PORT = i
            tport.close()
            break
        except serial.SerialException as e:
            pass
        except ValueError as e:
            pass
    else:
        print("Failed to detect serial port")
        exit(1)

# Figure out the number of channels
#if(len(sys.argv) != 2):
#    print("Usage: %s [channels]" % (sys.argv[0]))
#    exit()
#CHANNELS = int(sys.argv[1])
CHANNELS = 1

# Data generator that reads from a serial port
class SerialDataSource(threading.Thread):
    def __init__(self, channels, handler):
        threading.Thread.__init__(self)
        self.daemon = True
        self.handler = handler
        self.channels = channels
        
        self.port = serial.Serial(SERIAL_PORT, BAUD_RATE)

    def run(self):
        idx = 0
        fmt = "<I"+"H"*CHANNELS
        while True:
            buf = self.port.read(2*CHANNELS + 4)
            dblk = struct.unpack(fmt, buf)
            usecs = dblk[0]
            data = dblk[1:]
            self.handler(usecs, data)

# Random data generator for testing purposes
class RandomDataSource(threading.Thread):
    def __init__(self, channels, handler):
        threading.Thread.__init__(self)
        self.daemon = True
        
        self.vel = [0]*channels
        self.pos = [random.randint(MIN_VALUE,MAX_VALUE) for i in range(channels)]
        self.channels = channels
        self.handler = handler

        self.last_update = time.time()

    def update_channels(self):
        dt = time.time() - self.last_update
        self.last_update = time.time()
        for i in range(self.channels):
            self.vel[i] = random.uniform(-256,256)
            self.pos[i] = max(MIN_VALUE,min(MAX_VALUE,self.pos[i] + (self.vel[i]*dt)))

    def run(self):
        while True:
            for idx in range(self.channels):
                self.handler(idx, int(self.pos[idx]))
            time.sleep(0.025)
            self.update_channels()

# strptime-compatible formatting string to make ISO 8601 time strings
ISO_8601_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S"

# Data writer emitting to a CSV file. Lines emitted are of the format:
# channel_index, time, value
class CSVDataSink:
    def __init__(self, argstr):
        filename = "data_%s.csv" % time.strftime("%d-%m-%Y_%H-%M-%S")
        print("Writing to: %s" % os.path.join(os.getcwd(), filename))
        self.fileobj = open(filename, "w")
        self.file = csv.writer(self.fileobj, dialect='excel-tab')

    def accept_round(self, adjtime, values):
        #tstamp = (time.strftime("%Y/%m/%d-%H:%M:%S", adjtime) if HUMAN_TIMESTAMPS
        #          else adjtime)
        try:
            self.file.writerow([adjtime]+list(values))
            self.data_lines = []
        except AttributeError:
            pass

    def close(self):
        del self.file
        while True:
            try:
                self.fileobj.close()
            except IOError:
                continue
            break

# Data writer emitting to a binary file
class BinaryDataSink:
    def __init__(self, args):
        f = open("data_%s.bin" % time.strftime(ISO_8601_TIME_FORMAT), "wb")
        self.file = f

    def accept_round(self, adjtime, values):
        self.file.write(struct.pack(">BfH", idx, adjtime, value))

    def close(self):
        self.file.close()

# Writer that drops all data
class NullDataSink:
    def __init__(self, args):
        pass

    def accept_round(self, idx, adjtime, value):
        pass

    def close(self):
        pass

# Open a window
SIZE = (800,600)
WINDOW_SIZE = 10
GRAD_ATOM = 1
COLOR_TABLE = {}

# Generate color table
COLOR_MAP = []
for basis in [0xff, 0x80, 0xc0, 0x40, 0x20, 0x60, 0xa0, 0xe0]:
    for template in '100 010 001 110 101 011 111'.split(' '):
        COLOR_MAP.append(tuple(map(lambda c: basis*int(c), template)))
for i in range(CHANNELS):
    COLOR_TABLE[i] = COLOR_MAP[i]

pygame.init()
pygame.font.init()
scr = pygame.display.set_mode(SIZE, RESIZABLE)
TIMEBASE = time.time()

class Application:
    def __init__(self, nchan):
        self.channels = {}
        self.time_base = time.time()
        for i in range(CHANNELS):
            self.channels[i] = []
        self.font = pygame.font.SysFont(pygame.font.get_default_font(), 20)
        self.enable = [True for y in range(CHANNELS)]

        # Open the writer
        try:
            mode_fmt = SINK_MODE[:3]
            args = SINK_MODE[3:].strip(':')
            if mode_fmt == 'csv':
                self.sink = CSVDataSink(args)
            elif mode_fmt == 'bin':
                self.sink = BinaryDataSink(args)
        except IOError as e:
            print("Error: Unable to open output file: %s" % e.strerror)
            self.sink = NullDataSink(args)

        self.rebuild_subrenderers()

    def rebuild_subrenderers(self):
        # Build sub-rendering surfaces
        self.graph_surf = pygame.Surface((SIZE[0]//6*5,SIZE[1])).convert()
        self.rt_surf = pygame.Surface((SIZE[0]//6, SIZE[1])).convert()
        self.graph_base = pygame.Surface(self.graph_surf.get_size()).convert()
        self.graph_inner = self.graph_surf.subsurface(pygame.Rect(40, 0,
            self.graph_base.get_width()-40, self.graph_base.get_height()-40))

        self.render_graph_base()
    
    def handle_push(self, usecs, values):
        ct = TIMEBASE + (usecs * 1e-6)
        self.sink.accept_round(ct, values)

        min_time = ct - WINDOW_SIZE

        for idx in range(len(values)):
            self.channels[idx].append((ct, values[idx]))
            if len(self.channels[idx]) > 4:
                while self.channels[idx][1][0] < min_time:
                    self.channels[idx].pop(0)

    # Render the basic graph axes and vertical scale
    def render_graph_base(self):
        size = self.graph_base.get_size()
        self.graph_base.fill((0,0,0))

        # Render graph axes
        axes_size = (size[0]-40, size[1]-40)
        pygame.draw.aaline(self.graph_base, (0,255,0), (40,size[1]-40),
                (size[0],size[1]-40)) # Horizontal
        pygame.draw.aaline(self.graph_base, (0,255,0), (40,0),
                (40,size[1]-40)) # Vertical

        gradations = 16
        increment = axes_size[1]/gradations
        for i in range(0,gradations):
            pos = (40, size[1]-40-(increment*i))
            pygame.draw.aaline(self.graph_base, (0,255,0), (pos[0]-10, pos[1]),
                    (pos[0], pos[1]))
            addr = int(((MAX_VALUE-MIN_VALUE) * (i/gradations))+MIN_VALUE)
            fo = self.font.render(str(addr), True, (0,255,0))
            
            # Render the font onto the surface at a centered position
            self.graph_base.blit(fo, (pos[0]-fo.get_width()-15,
                pos[1]-(fo.get_height()//2)))

    def render_graph(self):
        now = time.time() - self.time_base
        self.graph_surf.blit(self.graph_base, (0,0))
        size = self.graph_surf.get_size()
        axes_size = (size[0]-40, size[1]-40)

        # Compute bounds of horizontal scale
        upper_scale_bound = now
        lower_scale_bound = upper_scale_bound - WINDOW_SIZE
        scale_width = upper_scale_bound - lower_scale_bound

        # Figure out value of first gradation
        fg_value = GRAD_ATOM*math.ceil(lower_scale_bound / GRAD_ATOM)

        def draw_gradation(t):
            if(t<0):
                return
            frac = (t - lower_scale_bound) / scale_width
            xpos = 40+int(frac*axes_size[0])
            pygame.draw.aaline(self.graph_surf, (0,255,0), (xpos, size[1]-40),
                    (xpos, size[1]-30))
            fo = self.font.render(str(int(t)), True, (0,255,0))
            self.graph_surf.blit(fo, (xpos-(fo.get_width()//2),
                size[1]-30+fo.get_height()))

        # Draw gradations from there at each 0.5s mark
        grad_time = fg_value
        while grad_time < upper_scale_bound:
            draw_gradation(grad_time)
            grad_time += GRAD_ATOM

        # Get the graphing subsurface
        self.graph_data(self.graph_inner, lower_scale_bound+self.time_base,
                upper_scale_bound+self.time_base)

    def graph_data(self, surf, lb, ub):
        scale_width = ub - lb
        width = surf.get_width()
        height = surf.get_height()
        scale_value = lambda v: (v-MIN_VALUE)/(MAX_VALUE-MIN_VALUE)

        def convert_point(val):
            time,y = val
            frac = (time-lb)/scale_width
            return (int(frac*width), height-int(height*scale_value(y)))

        # Begin graphing data
        for k,d in self.channels.iteritems():
            if len(d) < 2 or not self.enable[k]:
                continue
            clr = COLOR_TABLE[k]
            points = map(convert_point, d)
            pygame.draw.lines(surf, clr, False, points)

    def render_realtime(self):
        self.rt_surf.fill((0,0,0))
        inner_height = self.graph_inner.get_height()
        over_height = self.rt_surf.get_height()

        def scale_value(v):
            frac = (v-MIN_VALUE)/(MAX_VALUE-MIN_VALUE)
            return over_height - (int(frac*inner_height) + 40)

        if min(list(map(len, self.channels.values()))) == 0:
            return

        # Draw labels
        for i in range(CHANNELS):
            upper = 5+(i*25)

            # Draw the outer component
            clr = COLOR_TABLE[i]
            self.rt_surf.fill(clr, pygame.Rect(10, upper, 20, 20))

            # Draw value label
            if self.enable[i]:
                fo = self.font.render(str(self.channels[i][-1][1]), True, clr)
                self.rt_surf.blit(fo, (35, upper+2))

            # Unfill inner component if needed
            idx_color = (0,0,0)
            if(not self.enable[i]):
                self.rt_surf.fill((0,0,0), pygame.Rect(12,upper+2,16,16))
                idx_color = clr
            
            # Draw label index centered
            fo = self.font.render(str(i), True, idx_color)
            self.rt_surf.blit(fo,
                (12+(0.5*(16-fo.get_width())),
                    upper+2+(0.5*(16-fo.get_height()))))

    def render(self):
        global scr
        self.render_graph()
        self.render_realtime()
        
        scr.blit(self.graph_surf, (0,0))
        scr.blit(self.rt_surf, (self.graph_surf.get_width(),0))
        pygame.display.flip()

    def run(self):
        global scr, SIZE
        clk = pygame.time.Clock()
        run = True
        while run:
            self.render()
            
            for e in pygame.event.get():
                if e.type == QUIT:
                    run = False
                elif e.type == VIDEORESIZE:
                    scaled = pygame.transform.scale(scr, e.dict['size'])
                    scr = pygame.display.set_mode(e.dict['size'], RESIZABLE)
                    scr.blit(scaled, (0,0))
                    SIZE = e.dict['size']
                    self.rebuild_subrenderers()
                    pygame.display.flip()
                elif e.type == MOUSEBUTTONUP and e.button == 1:
                    # Check position
                    pos = e.pos
                    rtbase = self.rt_surf.get_rect()
                    pos = (pos[0]-self.graph_surf.get_width(), pos[1])
                    if not rtbase.collidepoint(pos):
                        # Must be on RT surface
                        continue
                    if pos[0] > 30 or pos[0] < 10:
                        # Must be click on item
                        continue
                    if pos[1] < 5 or pos[1] > CHANNELS*25:
                        continue
                    xidx = (pos[1]-5) // 25
                    offset = (pos[1]-5) % 25
                    if offset > 20:
                        continue

                    # Click detected
                    self.enable[xidx] = not self.enable[xidx]
            clk.tick(60)
        self.sink.close()

app = Application(CHANNELS)
gen = None
if USE_SERIAL:
    gen = SerialDataSource(CHANNELS, app.handle_push)
else:
    gen = RandomDataSource(CHANNELS, app.handle_push)
gen.start()
app.run()
pygame.quit()
