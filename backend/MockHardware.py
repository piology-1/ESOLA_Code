class MockHardware:

    def open_door(self, door):
        print("%d. Tür von oben wurde geöffnet." % (door+1))

    def rotate_to_position(self, pos):
        print("Turm wurde in Stellung %d gedreht." % pos)
