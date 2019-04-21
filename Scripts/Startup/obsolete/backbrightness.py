#!/usr/bin/env python3

# based on:
# https://gist.github.com/joel-wright/68fc3031cbb3f7cd25db1ed2fe656e60

import os
import time
from pathlib import Path
from functools import lru_cache

import xcffib
import xcffib.randr
import subprocess
import socket

UINT16_MAX = 2**16 - 1

# this has the happy consequence of resetting gamma
class BrightnessSetter():
    def __init__(self, output_names=[], display_name=None, screen_num=None):
        self.connection = None
        self.output_names = output_names
        self.display_name = display_name
        self.screen_num = screen_num
        self.target_crtcs = []

    def __find_crtcs(self):
        self.target_crtcs = []
        not_found = self.output_names[:]
        randr = self.randr
        for crtc in randr.GetScreenResources(self.screen.root).reply().crtcs:
            crtc_info = randr.GetCrtcInfo(crtc, int(time.time())).reply()
            for output in crtc_info.outputs:
                output_info = randr.GetOutputInfo(output, int(time.time())).reply()
                name = bytes(output_info.name).decode('ascii')
                if name in self.output_names:
                    self.target_crtcs.append(crtc)
                    not_found.remove(name)
        for name in not_found:
            print('Warning: output {} not found!'.format(name))

    def connect(self):
        def default_if_none(value, default):
            if value is None:
                return default
            return value

        if not self.connection:
            disp_name = default_if_none(self.display_name, os.environ.get('DISPLAY'))
            self.connection = con = xcffib.connect(disp_name)
            screen_num = default_if_none(self.screen_num, con.pref_screen)
            self.screen = con.get_setup().roots[screen_num]
            self.randr = con(xcffib.randr.key)
            self.__find_crtcs()

        return self.randr

    @lru_cache(maxsize=10)
    def generate_gamma_table(self, size, brightness=1.0, gamma=1.0):
        calc = lambda i: int(min(pow(i/(size - 1), gamma) * brightness, 1.0) * UINT16_MAX)
        return list(calc(i) for i in range(size))

    def set_brightness(self, brightness):
        randr = self.connect()
        for crtc in self.target_crtcs:
            #print('set {} brightness for crtc {}:'.format(brightness, crtc))
            cur_gamma = randr.GetCrtcGamma(crtc).reply()
            size = cur_gamma.size
            adjusted = self.generate_gamma_table(size, brightness)
            #commented out gamma reset
            #reply = randr.SetCrtcGamma(crtc, size, adjusted, adjusted, adjusted)
        self.connection.flush()

def translate_backlight(setter, backlight_path, sleep_time):
    max_path = backlight_path / 'max_brightness'
    actual_path = backlight_path / 'actual_brightness'

    while True:
        with open(str(max_path), 'rt') as max_file, open(str(actual_path), 'rt') as actual_file:
            max_brightness = int(max_file.read())
            actual_brightness = int(actual_file.read())
            
        brightness = actual_brightness / max_brightness
        
        #Added a conditional to check for a connection 
        
        REMOTE_SERVER = "1.1.1.1"
        def is_connected():
            try:
                host = socket.gethostbyname(REMOTE_SERVER)
                s = socket.create_connection((host, 80), 2)
                return True
            except:
                pass
            return False
        
        #Added redshift subprocess dependent on connection. Durham location: '35.996948:-78.899017' or use geoclue2 when connected
    
        if is_connected():
            print ("connected")
            subprocess.check_call(
            ['redshift', '-o', '-P', '-l', '36.02:-78.95',
            '-b', str(brightness)])
        else:
            print ("disconnected")
            subprocess.check_call(
            ['redshift', '-o', '-P', '-l', '35.996948:-78.899017',
            '-b', str(brightness)])
    
        setter.set_brightness(brightness)
        
        time.sleep(sleep_time)
        
def main():
    import argparse

    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-s', '--sleep-time', type=float, default=0.2, help='Time between two brightness updates')
    parser.add_argument('backlight_path', type=str, help='Path for the intel acpi backlight. For example "/sys/class/backlight/intel_backlight"')
    parser.add_argument('outputs', type=str, nargs='+', help="outputs whose brightness to adjust with randr. Check \"xrandr -q\" for values. Normally it should be eDP1 or eDP-1")
    #parser.add_argument('--location', '-l', type=str, help='geolocation called in setbrightness script.')

    args = parser.parse_args()

    setter = BrightnessSetter(args.outputs)
    translate_backlight(setter, Path(args.backlight_path), args.sleep_time)

    return 0

if __name__ == '__main__':
    import sys
    sys.exit( main() )
