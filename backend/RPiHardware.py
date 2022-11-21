import threading
import time

import RPi.GPIO as GPIO


class RPiHardware:

    door_pins = (29, 31, 33, 35, 37)

    def __init__(self):
        GPIO.setmode(GPIO.BOARD)
        for pin in self.door_pins:
            GPIO.setup(pin, GPIO.OUT)

    def __del__(self):
        GPIO.cleanup(self.door_pins)

    @staticmethod
    def _signal_pulse(pin):
        GPIO.output(pin, GPIO.HIGH)
        time.sleep(0.2)
        GPIO.output(pin, GPIO.LOW)

    def open_door(self, door):
        pin = self.door_pins[door]
        threading.Thread(target=self._signal_pulse, args=(pin,)).start()

    def rotate_to_position(self, pos):
        if pos != 0:
            raise NotImplementedError
