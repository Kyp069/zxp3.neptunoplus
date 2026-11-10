# zxp3

A Sinclair ZX Spectrum +3 FPGA implementation.

This is a specific implementation for neptuno+ board.

Uses:
- zxp3 fpga independent implementation: https://github.com/Kyp069/zxp3
- mist moudeles from mist-devel: https://github.com/mist-devel/mist-modules
- T80 from mist-devel: https://github.com/mist-devel/T80
- TZX player by György Szombathelyi

WARNING: Tape loading and MIDI require firmware CLP-0.25 or higher: https://github.com/shaeon/calypso-firmware/tree/neptuno-plus/ports/neptuno_plus

### Implements a standard ZX Spectrum +3 computer and the follwing hardware:

- Turbosound
- Tape loading: TAP, TZT, PZX
- Two Floppy disk drives
- ZXMMC/DIVMMC disk images
- Dual Sinclair joysticks
- Dual Kempston Joystick with two fire buttons (ZX-Next ports)
- K-Mouse
- MIDI

A ROM file must be copied to the root directory of the SD card as "zxp3.rom". It is a 72 KB file containing the Spectrum ROM (64 KB) and the esxDOS ROM (8 KB). You can change it at any time via the on-screen display (OSD) menu (accessed by pressing the F12 key).

Any ROM compatible with the +3 is supported, such as the standard Amstrad ROM and Garry Lancaster’s +3e ROM.
If you are going to use Garry Lancaster's +3e ROM, you need to disable the DivMMC in the OSD.

Kempston mouse and Kempston joystick cannot be used simultaneously. At any time, press any mouse button to activate Kempston mouse mode and disable the joystick or press any fire button on the joystick to activate Kempston joystick mode and disable the mouse.

Keyboard shortcuts:
- F9: reset
- F5: NMI
- F12: OSD
- Pg Up: start playing tape
- Pg Down: stop playing tape

### Useful links

Garry Lancaster's +3e ROM:
https://worldofspectrum.org/zxplus3e/

desUBIKado's Mar Océana image file for +3e:
http://www.retrowiki.es/viewtopic.php?f=110&t=200037816

Octocom's Workbench +e3:
https://octocom.speccy.org/workbench_es.html
