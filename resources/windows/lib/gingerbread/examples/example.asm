
; This section is for including files that either need to be in the home section, or files where it doesn't matter 
SECTION "Includes@home",ROM0

; Prior to importing GingerBread, some options can be specified

; Max 15 characters, should be uppercase ASCII
GAME_NAME EQUS "GBEXAMPLE " 

; Include SGB support in GingerBread. This makes the GingerBread library take up a bit more space on ROM0. To remove support, comment out this line (don't set it to 0)
SGB_SUPPORT EQU 1 

; Include GBC support in GingerBread. This makes the GingerBread library take up slightly more space on ROM0. To remove support, comment out this line (don't set it to 0)
GBC_SUPPORT EQU 1

; Set the size of the ROM file here. 0 means 32 kB, 1 means 64 kB, 2 means 128 kB and so on.
ROM_SIZE EQU 1 

; Set the size of save RAM inside the cartridge. 
; If printed to real carts, it needs to be small enough to fit. 
; 0 means no RAM, 1 means 2 kB, 2 -> 8 kB, 3 -> 32 kB, 4 -> 128 kB 
RAM_SIZE EQU 1 

INCLUDE "gingerbread.asm"

; To compile this game without gbt-player, comment out this line (don't set it to 0)
USE_GBT_PLAYER EQU 1

; This section is for including files that need to be in data banks
SECTION "Include@banks",ROMX
INCLUDE "images/title.inc"
INCLUDE "images/pong.inc"
INCLUDE "images/sgb_border.inc"

IF DEF(USE_GBT_PLAYER)
INCLUDE "gbt_player.inc"
ENDC

; Macro for copying a rectangular region into VRAM
; Changes ALL registers
; Arguments:
; 1 - Height (number of rows)
; 2 - Width (number of columns)
; 3 - Source to copy from
; 4 - Destination to copy to
CopyRegionToVRAM: MACRO

I SET 0
REPT \1

    ld bc, \2
    ld hl, \3+(I*\2)
    ld de, \4+(I*32)
    
    call mCopyVRAM
    
I SET I+1
ENDR
ENDM    
    
SECTION "StartOfGameCode",ROM0    
begin: ; GingerBread assumes that the label "begin" is where the game should start
    
    call SetupSGB
    call SetupGBC
    
    ; Load title image into VRAM
    
    ; We need to switch bank to whatever bank contains the tile data 
    ld a, BANK(title_tile_data)
    ld [ROM_BANK_SWITCH], a 
    
    ld hl, title_tile_data
    ld de, TILEDATA_START
    ld bc, title_tile_data_size
    call mCopyVRAM
    
    ld a, BANK(title_map_data)
    ld [ROM_BANK_SWITCH], a 
    
    CopyRegionToVRAM 18, 20, title_map_data, BACKGROUND_MAPDATA_START
    
    call StartLCD
    
    ; Everything up to this point is simply an example demo which shows a single image. If you want
    ; to use this as your starting point, remove all lines below.
    
    call EnableAudio
    
    call SetupHighScore

IF DEF(USE_GBT_PLAYER)   
    ld      de,funkyforest_data
    ld      bc,BANK(funkyforest_data)
    ld      a,$05
    call    gbt_play ; Play song
ENDC 
    
    ld a, 1 
    ld [ROM_BANK_SWITCH], a 
    
    jp TitleLoop
    
; Definition of some RAM variables 
SECTION "RAM variables",WRAM0[USER_RAM_START]
BALL_POSITION: DS 2
BALL_DIRECTION: DS 2 
LEFT_PADDLE_POSITION: DS 2
RIGHT_PADDLE_POSITION: DS 2  
RIGHT_PADDLE_CHECK_TIME: DS 1 
RIGHT_PADDLE_DIRECTION: DS 1
LEFT_SCORE: DS 1
RIGHT_SCORE: DS 1 

SECTION "SRAM variables",SRAM[SAVEDATA_START]
SRAM_INTEGRITY_CHECK: DS 2 ; Two bytes that should read $1337; if they do not, the save is considered corrupt or unitialized
SRAM_HIGH_SCORE: DS 1 


; Definition of some constants
PADDLE_SPEED                    equ 2 ; pixels per frame   
RIGHT_PADDLE_CHECK_FREQUENCY    equ 15 ; how many frame should pass between each check if right paddle should move up/down 

SECTION "Text definitions",ROM0 
; Charmap definition (based on the pong.png image, and looking in the VRAM viewer after loading it in BGB helps finding the values for each character)
CHARMAP "A",$56
CHARMAP "B",$57
CHARMAP "C",$58
CHARMAP "D",$59
CHARMAP "E",$5A
CHARMAP "F",$5B
CHARMAP "G",$5C
CHARMAP "H",$5D
CHARMAP "I",$5E
CHARMAP "J",$5F
CHARMAP "K",$60
CHARMAP "L",$61
CHARMAP "M",$62
CHARMAP "N",$63
CHARMAP "O",$64
CHARMAP "P",$65
CHARMAP "Q",$66
CHARMAP "R",$67
CHARMAP "S",$68
CHARMAP "T",$69
CHARMAP "U",$6A
CHARMAP "V",$6B
CHARMAP "W",$6C
CHARMAP "X",$6D
CHARMAP "Y",$6E
CHARMAP "Z",$6F
CHARMAP "<happy>",$70
CHARMAP "<sad>",$71
CHARMAP "<heart>",$72
CHARMAP " ",$01
CHARMAP "<end>",$0 ; Choose some non-character tile that's easy to remember 

; Text definitions 
SupportiveText:
DB "WELL DONE <happy> <heart> <end>"

TauntingText:
DB "YOU SUCK LOL <sad><end>"

GameOverText:
DB "GAME OVER LOLOLOLO<end>"

SECTION "Sound effect definitions",ROM0
Sound_ball_bounce:
DW SOUND_CH4_START
DB %00000000 ; Data to be written to SOUND_CH4_START
DB %00000100 ; Data to be written to SOUND_CH4_LENGTH
DB %11110111 ; Data to be written to SOUND_CH4_ENVELOPE 
DB %01010101 ; Data to be written to SOUND_CH4_POLY 
DB %11000110 ; Data to be written to SOUND_CH4_OPTIONS

SECTION "SGB Palette data",ROMX,BANK[1]
SGBPalettes01: ; Specifies the colors of palettes 0 and 1 
DB %00000001 ; PAL01 command (%00000), length one (%001)
DB %11111111 ; Color 0 (for all palettes), %gggrrrrr
DB %01111111 ; Color 0 (for all palettes), %0bbbbbgg
DB %11100001 ; Color 1, Palette 0, %gggrrrrr
DB %01111001 ; Color 1, Palette 0, %0bbbbbgg
DB %01100001 ; Color 2, Palette 0, %gggrrrrr
DB %00110100 ; Color 2, Palette 0, %0bbbbbgg
DB %00000000 ; Color 3, Palette 0, %gggrrrrr
DB %00000000 ; Color 3, Palette 0, %0bbbbbgg
DB %11100111 ; Color 1, Palette 1, %gggrrrrr
DB %01111001 ; Color 1, Palette 1, %0bbbbbgg
DB %11100001 ; Color 2, Palette 1, %gggrrrrr
DB %00011101 ; Color 2, Palette 1, %0bbbbbgg
DB %00000000 ; Color 3, Palette 1, %gggrrrrr
DB %00000000 ; Color 3, Palette 1, %0bbbbbgg
DB 0         ; Not used 

SGBPalettes23: ; Specifies the colors of palettes 2 and 3
DB %00001001 ; PAL23 command (%00001), length one (%001)
DB %11111111 ; Color 0 (for all palettes), %gggrrrrr
DB %01111111 ; Color 0 (for all palettes), %0bbbbbgg
DB %10110101 ; Color 1, Palette 2, %gggrrrrr
DB %01010110 ; Color 1, Palette 2, %0bbbbbgg
DB %11100111 ; Color 2, Palette 2, %gggrrrrr
DB %00011100 ; Color 2, Palette 2, %0bbbbbgg
DB %00100001 ; Color 3, Palette 2, %gggrrrrr
DB %00000100 ; Color 3, Palette 2, %0bbbbbgg
DB 0,0,0,0,0,0 ; Colors 1-3, Palette 3 (which isn't used in this example game)

SGBPal2Everywhere: ; Tells the SGB to use Palette 2 everywhere (used for title and game over)
DB %00100001 ; ATTR_BLK (%00100), length one (%001)
DB 1         ; Number of blocks we send
DB %00000100 ; Set the value "outside" the block (doing this with a small block means setting the entire screen)
DB %00101010 ; Which palettes to set inside (%10), on the border (%10) and outside (%10)
DB 0         ; X1 coordinate
DB 0         ; Y1 coordinate 
DB 0         ; X2 coordinate 
DB 0         ; Y2 coordinate 
DB 0,0,0,0,0,0,0,0 ; Zero-padding

SGBPal01Div: ; Tells the SGB to draw the top horizontal line with palette 1, and palette 0 everywhere else  
DB %00110001 ; ATTR_DIV command (%00110), length one (%001)
DB %01010100 ; Zero-padding (%0), horizontal split (%1), palette on the line (%01), palette above the line (%01), palette below the line (%00)
DB 0         ; Y-coordinate 
DB 0,0,0,0,0,0,0,0,0,0,0,0,0 ; Zero-padding

SECTION "GBC Palette data",ROM0
GBCBackgroundPalettes:
DB %11111111 ; Color 0, palette 0, %gggrrrrr
DB %01111111 ; Color 0, palette 0, %0bbbbbgg
DB %11100011 ; Color 1, palette 0, %gggrrrrr
DB %00011111 ; Color 1, palette 0, %0bbbbbgg
DB %11100001 ; Color 2, palette 0, %gggrrrrr
DB %00001001 ; Color 2, palette 0, %0bbbbbgg
DB %00000000 ; Color 3, palette 0, %gggrrrrr
DB %00000000 ; Color 3, palette 0, %0bbbbbgg
DB %11111111 ; Color 0, palette 1, %gggrrrrr
DB %01111111 ; Color 0, palette 1, %0bbbbbgg 
DB %01111111 ; Color 1, palette 1, %gggrrrrr
DB %00001100 ; Color 1, palette 1, %0bbbbbgg
DB %01001111 ; Color 2, palette 1, %gggrrrrr
DB %00000100 ; Color 2, palette 1, %0bbbbbgg
DB %00000011 ; Color 3, palette 1, %gggrrrrr
DB %00000000 ; Color 3, palette 1, %0bbbbbgg

GBCBackgroundPalettesDark:
DB %11100111 ; Color 0, palette 0, %gggrrrrr
DB %00011100 ; Color 0, palette 0, %0bbbbbgg
DB %11100000 ; Color 1, palette 0, %gggrrrrr
DB %00000100 ; Color 1, palette 0, %0bbbbbgg
DB %01100000 ; Color 2, palette 0, %gggrrrrr
DB %00000100 ; Color 2, palette 0, %0bbbbbgg
DB %00000000 ; Color 3, palette 0, %gggrrrrr
DB %00000000 ; Color 3, palette 0, %0bbbbbgg
DB %11100111 ; Color 0, palette 1, %gggrrrrr
DB %00011100 ; Color 0, palette 1, %0bbbbbgg 
DB %00000111 ; Color 1, palette 1, %gggrrrrr
DB %00000000 ; Color 1, palette 1, %0bbbbbgg
DB %00000011 ; Color 2, palette 1, %gggrrrrr
DB %00000000 ; Color 2, palette 1, %0bbbbbgg
DB %00000000 ; Color 3, palette 1, %gggrrrrr
DB %00000000 ; Color 3, palette 1, %0bbbbbgg

GBCBackgroundPalettesDarker:
DB %01000010 ; Color 0, palette 0, %gggrrrrr
DB %00001000 ; Color 0, palette 0, %0bbbbbgg
DB %01000000 ; Color 1, palette 0, %gggrrrrr
DB %00000000 ; Color 1, palette 0, %0bbbbbgg
DB %01000000 ; Color 2, palette 0, %gggrrrrr
DB %00000000 ; Color 2, palette 0, %0bbbbbgg
DB %00000000 ; Color 3, palette 0, %gggrrrrr
DB %00000000 ; Color 3, palette 0, %0bbbbbgg
DB %01000010 ; Color 0, palette 1, %gggrrrrr
DB %00001000 ; Color 0, palette 1, %0bbbbbgg 
DB %00000010 ; Color 1, palette 1, %gggrrrrr
DB %00000000 ; Color 1, palette 1, %0bbbbbgg
DB %00000000 ; Color 2, palette 1, %gggrrrrr
DB %00000000 ; Color 2, palette 1, %0bbbbbgg
DB %00000000 ; Color 3, palette 1, %gggrrrrr
DB %00000000 ; Color 3, palette 1, %0bbbbbgg

GBCBackgroundPalettesDarkest:
DB %00000000 ; Color 0, palette 0, %gggrrrrr
DB %00000000 ; Color 0, palette 0, %0bbbbbgg
DB %00000000 ; Color 1, palette 0, %gggrrrrr
DB %00000000 ; Color 1, palette 0, %0bbbbbgg
DB %00000000 ; Color 2, palette 0, %gggrrrrr
DB %00000000 ; Color 2, palette 0, %0bbbbbgg
DB %00000000 ; Color 3, palette 0, %gggrrrrr
DB %00000000 ; Color 3, palette 0, %0bbbbbgg
DB %00000000 ; Color 0, palette 1, %gggrrrrr
DB %00000000 ; Color 0, palette 1, %0bbbbbgg 
DB %00000000 ; Color 1, palette 1, %gggrrrrr
DB %00000000 ; Color 1, palette 1, %0bbbbbgg
DB %00000000 ; Color 2, palette 1, %gggrrrrr
DB %00000000 ; Color 2, palette 1, %0bbbbbgg
DB %00000000 ; Color 3, palette 1, %gggrrrrr
DB %00000000 ; Color 3, palette 1, %0bbbbbgg

GBCSpritePalettes:
DB %11111111 ; Color 0, palette 0, %gggrrrrr
DB %01111111 ; Color 0, palette 0, %0bbbbbgg
DB %11111111 ; Color 1, palette 0, %gggrrrrr
DB %00011111 ; Color 1, palette 0, %0bbbbbgg
DB %11111111 ; Color 2, palette 0, %gggrrrrr
DB %00001001 ; Color 2, palette 0, %0bbbbbgg
DB %00000000 ; Color 3, palette 0, %gggrrrrr
DB %00000000 ; Color 3, palette 0, %0bbbbbgg
DB %11111000 ; Color 0, palette 1, %gggrrrrr
DB %01111111 ; Color 0, palette 1, %0bbbbbgg 
DB %01100000 ; Color 1, palette 1, %gggrrrrr
DB %01111100 ; Color 1, palette 1, %0bbbbbgg
DB %00000000 ; Color 2, palette 1, %gggrrrrr
DB %00011100 ; Color 2, palette 1, %0bbbbbgg
DB %00000000 ; Color 3, palette 1, %gggrrrrr
DB %00001100 ; Color 3, palette 1, %0bbbbbgg

GBCPaletteMap:
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SECTION "Pong game code",ROM0
SetupGBC:
    GBCEarlyExit ; Prevents garbage from being written to tile map on non-GBC by the palette map. 
    
    ld hl, GBCBackgroundPalettes
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes

    ld hl, GBCSpritePalettes
    xor a 
    ld b, 16 
    call GBCApplySpritePalettes
    
    ; Switch to VRAM bank 1 to write the palette map (which palette to use at which tile)
    ld a, 1
    ld [GBC_VRAM_BANK_SWITCH], a 
    
    ; Copy the palette map onto VRAM (where the tile data usually is)
    CopyRegionToVRAM 18, 20, GBCPaletteMap, BACKGROUND_MAPDATA_START
    
    ; Change the VRAM bank back
    xor a 
    ld [GBC_VRAM_BANK_SWITCH], a 
    
    ret 
    
SetupSGB:
	SGBEarlyExit ; Without this, garbage would be visible on screen briefly when booting on a GB/GBC
	
    call InitSGBPalettes
    
	call SGBFreeze ; To prevent "garbage" from being visible on screen 
	
    SGBBorderTransferMacro SGB_VRAM_TILEDATA1, SGB_VRAMTRANS_TILEDATA1, SGB_VRAMTRANS_GBTILEMAP
    SGBBorderTransferMacro SGB_VRAM_TILEDATA2, SGB_VRAMTRANS_TILEDATA2, SGB_VRAMTRANS_GBTILEMAP
    SGBBorderTransferMacro SGB_VRAM_TILEMAP, SGB_VRAMTRANS_TILEMAP, SGB_VRAMTRANS_GBTILEMAP   
    
	call SGBUnfreeze
	ret
    
SetupSGBGameplay:
    ; Sets up palette usage which should be displayed during gameplay
    
    SGBEarlyExit    
    ld hl, SGBPal01Div
    call SGBSendData
    
    ret 

InitSGBPalettes:
    ld hl, SGBPalettes01
    call SGBSendData
    
    ld hl, SGBPalettes23
    call SGBSendData
    
    ld hl, SGBPal2Everywhere
    call SGBSendData
    
    ret 
    
SetupHighScore:
    ; For this game, we only ever use one save data bank, the first one (0)
    xor a 
    call ChooseSaveDataBank
    
    ; Activate save data so we can read and write it 
    call EnableSaveData
    
    ; If the integrity check doesn't read $1337, we should initialize a default high score of 0 and then write $1337 to the integrity check position 
    ld a, [SRAM_INTEGRITY_CHECK]
    cp $13
    jr nz, .initializeSRAM
    
    ld a, [SRAM_INTEGRITY_CHECK+1]
    cp $37
    jr nz, .initializeSRAM
    
    ; If we get here, no initialization is necessary
    jr .print
    
.initializeSRAM:
    ; Initialize high score to 0 
    xor a 
    ld [SRAM_HIGH_SCORE], a 
    
    ; Intialize integrity check so that high score will not be overwritten on next boot 
    ld a, $13
    ld [SRAM_INTEGRITY_CHECK], a 
    
    ld a, $37
    ld [SRAM_INTEGRITY_CHECK+1], a 
    
    jr .print
    
.print:
    ; Display current high score 
    ld a, [SRAM_HIGH_SCORE]
    ld b, a 
    
    call DisableSaveData ; Since we no longer need it. Always disable SRAM as quickly as possible.
    
    ld a, b 
    ld b, $4F ; tile number of 0 character on the title screen   
    ld c, 0   ; draw to background
    ld d, 8   ; X position 
    ld e, 14  ; Y position 
    call RenderTwoDecimalNumbers
    
    ret 

; To keep music playing at all times, call this before every halt command 
; A - ROM bank to switch to after updating music (GBT Player switches banks when updating the music)    
UpdateMusic:    
IF DEF(USE_GBT_PLAYER)
    push bc 
    push af 
    call gbt_update
    pop af 
    pop bc 
ENDC
    ld [ROM_BANK_SWITCH], a 
    ret 
    
TitleLoop:

    ld a, 1 
    call UpdateMusic
    
    halt
    nop ; Always do a nop after a halt, because of a CPU bug
    
    call ReadKeys
    and KEY_A | KEY_START
    cp 0
    
    jp nz, TransitionToGame
    
    jr TitleLoop
    
ShortWait:
    ld b, 20
    
.loop:    
    ld a, 1 
    call UpdateMusic

    halt 
    nop 
    
    dec b 
    ld a, b
    cp 0 
    jr nz, .loop 
    
    ret 

; Modifies everything    
DrawScore:    
    ; We use the -ByPosition render calls because this is done every frame, so precomputing the position numbers at compile time
    ; will make the code run faster 

    ld a, [LEFT_SCORE]
    ld b, $4C ; Tile number of 0 
    ld c, 0 ; Write to background 
    ld de, 1 + 32*0 ; Position number (the formula is x + 32*y)
    call RenderTwoDecimalNumbersByPosition
    
    ld a, [RIGHT_SCORE]
    ld b, $4C ; Tile number of 0
    ld c, 0 ; Write to background 
    ld de, 17 + 32*0 ; Position number (the formula is x + 32*y)  
    call RenderTwoDecimalNumbersByPosition
    
    ret 
    
; Modifies AF
DrawBall:    
    ; Left part of ball
    ld a, [BALL_POSITION+1] ; Y location
    ld [SPRITES_START], a
    ld a, [BALL_POSITION] ; X location 
    ld [SPRITES_START+1], a 
    ld a, $48 ; Tile number 
    ld [SPRITES_START+2], a
    xor a ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+3], a 
    
    ; Right part of ball
    ld a, [BALL_POSITION+1] ; Y location
    ld [SPRITES_START+4], a
    ld a, [BALL_POSITION] ; X location
    add 8 ; right part of ball should be 8 pixels to the right     
    ld [SPRITES_START+5], a 
    ld a, $4A ; Tile number 
    ld [SPRITES_START+6], a
    xor a ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+7], a     
    
    ret

; Modifies AF
DrawLeftPaddle:
    ; Top part of paddle
    ld a, [LEFT_PADDLE_POSITION+1] ; Y
    ld [SPRITES_START+8], a
    ld a, [LEFT_PADDLE_POSITION] ; X
    ld [SPRITES_START+9], a
    ld a, $44 ; Top and top-middle paddle tiles
    ld [SPRITES_START+10], a 
    ld a, 1 ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+11], a
    
    ; Bottom of paddle
    ld a, [LEFT_PADDLE_POSITION+1] ; Y
    add 16
    ld [SPRITES_START+12], a 
    ld a, [LEFT_PADDLE_POSITION] ; X
    ld [SPRITES_START+13], a 
    ld a, $46 ; Bottom-middle and bottom paddle tiles 
    ld [SPRITES_START+14], a 
    ld a, 1 ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+15], a 
    
    ret

; Modifies AF
DrawRightPaddle:
    ; Top part of paddle
    ld a, [RIGHT_PADDLE_POSITION+1] ; Y
    ld [SPRITES_START+16], a
    ld a, [RIGHT_PADDLE_POSITION] ; X
    ld [SPRITES_START+17], a
    ld a, $44 ; Top and top-middle paddle tiles
    ld [SPRITES_START+18], a 
    ld a, 1 ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+19], a
    
    ; Bottom of paddle
    ld a, [RIGHT_PADDLE_POSITION+1] ; Y
    add 16
    ld [SPRITES_START+20], a 
    ld a, [RIGHT_PADDLE_POSITION] ; X
    ld [SPRITES_START+21], a 
    ld a, $46 ; Bottom-middle and bottom paddle tiles 
    ld [SPRITES_START+22], a 
    ld a, 1 ; Flags (including GBC sprite color palette)
    ld [SPRITES_START+23], a 
    
    ret
    
TransitionToGame:
    ld a, %11111001
    ld [BG_PALETTE], a
    
    ld hl, GBCBackgroundPalettesDark
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ld a, %11111110
    ld [BG_PALETTE], a
    
    ld hl, GBCBackgroundPalettesDarker
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ld a, %11111111
    ld [BG_PALETTE], a
    
    ld hl, GBCBackgroundPalettesDarkest
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ; Now that the screen is completely black, load the game graphics
    
    ld a, BANK(pong_tile_data)
    ld [ROM_BANK_SWITCH], a
    
    ; Load pong tiles into VRAM 
    ld hl, pong_tile_data
    ld de, TILEDATA_START
    ld bc, pong_tile_data_size
    call mCopyVRAM
    
    ; Clear out the background 
    ld a, 1 
    ld hl, BACKGROUND_MAPDATA_START
    ld bc, 32*32
    call mSetVRAM
    
    ld a, BANK(pong_map_data)
    ld [ROM_BANK_SWITCH], a 
    
    ; Draw the pong map tiles 
    CopyRegionToVRAM 18, 20, pong_map_data, BACKGROUND_MAPDATA_START
    
    ld a, 1
    ld [ROM_BANK_SWITCH], a 
    
    ; On SGB, this is the right time to switch to the gameplay palettes
    call SetupSGBGameplay
    
    ; Now fade back to normal palette
    ld a, %11111110
    ld [BG_PALETTE], a
    
    ld hl, GBCBackgroundPalettesDarker
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ld a, %11111001
    ld [BG_PALETTE], a 
    
    ld hl, GBCBackgroundPalettesDark
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ld a, %11100100
    ld [BG_PALETTE], a 
    
    ld hl, GBCBackgroundPalettes
    xor a ; Start at color 0, palette 0 
    ld b, 16 ; We have 16 bytes to write
    call GBCApplyBackgroundPalettes
    
    call ShortWait
    
    ; Let's put the sprites in place
    
    ld a, 100 ; X
    ld [BALL_POSITION], a 
    ld a, 50 ; Y
    ld [BALL_POSITION+1], a
    call DrawBall
    
    ld a, 12 ; X
    ld [LEFT_PADDLE_POSITION], a
    ld a, 72 ; Y
    ld [LEFT_PADDLE_POSITION+1], a
    call DrawLeftPaddle
    
    ld a, 154 ; X
    ld [RIGHT_PADDLE_POSITION], a 
    ld a, 72 ; Y
    ld [RIGHT_PADDLE_POSITION+1], a 
    call DrawRightPaddle
    
    ; Set initial ball movement 
    ld a, 2 ; dx 
    ld [BALL_DIRECTION], a 
    ld a, 1 ; dy 
    ld [BALL_DIRECTION+1], a 
    
    ; Initialize right paddle check counter and direction 
    xor a 
    ld [RIGHT_PADDLE_CHECK_TIME], a 
    ld [RIGHT_PADDLE_DIRECTION], a 
    
    ; Initialize score 
    ld [LEFT_SCORE], a 
    ld [RIGHT_SCORE], a 
    
    jp GameLoop 

; Modifies AF 
; Moves the left paddle up, making sure not to move it outside the playing field 
MoveLeftPaddleUp:
    ld a, [LEFT_PADDLE_POSITION+1]
    sub PADDLE_SPEED
    
    ; Check if too high up 
    cp 24
    ret c 
    
    ld [LEFT_PADDLE_POSITION+1], a 
    ret 

; Modifies AF
; Same as MoveLeftPaddleUp, except Down     
MoveLeftPaddleDown:    
    ld a, [LEFT_PADDLE_POSITION+1]
    add PADDLE_SPEED
    
    ; Check if too far down 
    cp 130
    ret nc
    
    ld [LEFT_PADDLE_POSITION+1], a
    ret 


; Modifies AF 
; Moves the right paddle up, making sure not to move it outside the playing field 
MoveRightPaddleUp:
    ld a, [RIGHT_PADDLE_POSITION+1]
    sub PADDLE_SPEED
    
    ; Check if too high up 
    cp 24
    ret c 
    
    ld [RIGHT_PADDLE_POSITION+1], a 
    ret 

; Modifies AF
; Same as MoveRightPaddleUp, except Down     
MoveRightPaddleDown:    
    ld a, [RIGHT_PADDLE_POSITION+1]
    add PADDLE_SPEED
    
    ; Check if too far down 
    cp 130
    ret nc
    
    ld [RIGHT_PADDLE_POSITION+1], a
    ret 

    
ReverseBallDY:
    ; 0 - dy will be a positive integer, but it still works because of overflow
    xor a 
    sub c 
    ld [BALL_DIRECTION+1], a 
    ret
    
ReverseBallDX:
    xor a 
    sub b 
    ld [BALL_DIRECTION], a 
    ret 

CheckCollisionLeftPaddle:
    ; First check if the ball is far enough to the left 
    ld a, [BALL_POSITION]
    cp 17
    ret nc 
    
    ; Now check if it's far enough down 
    ld a, [LEFT_PADDLE_POSITION+1]
    ld d, a 
    ld a, [BALL_POSITION+1]
    add 8
    cp d 
    ret c
    
    ; Now check if it's not too far down 
    sub 40
    cp d 
    ret nc 
    
    call ReverseBallDX
    
    ld hl, Sound_ball_bounce
    call PlaySoundHL
    
    ; To prevent ball from getting stuck, make sure dx > 0 and it's a bit to the right 
    ld a, [BALL_POSITION]
    add 2 
    ld [BALL_POSITION], a 
    
    ld a, [BALL_DIRECTION]
    cp 128
    ret c 
    
    ; If we get here, it means ball direction was wrong 
    call ReverseBallDX
    ret 
    
CheckCollisionRightPaddle:
    ; First check if the ball is far enough to the right 
    ld a, [BALL_POSITION]
    cp 142
    ret c 
    
    ; Now check if it's far enough down 
    ld a, [RIGHT_PADDLE_POSITION+1]
    ld d, a 
    ld a, [BALL_POSITION+1]
    add 8
    cp d 
    ret c
    
    ; Now check if it's not too far down 
    sub 40
    cp d 
    ret nc 
    
    call ReverseBallDX    
    
    ld hl, Sound_ball_bounce
    call PlaySoundHL
    
    ; To prevent ball from getting stuck, make sure dx < 0 and it's a bit to the left 
    ld a, [BALL_POSITION]
    sub 2 
    ld [BALL_POSITION], a 
    
    ld a, [BALL_DIRECTION]
    cp 128
    ret nc 
    
    ; If we get here, it means ball direction was wrong 
    call ReverseBallDX
    ret 
    
CheckBallOut:
    ld a, [BALL_POSITION]
    ; If the x position is larger than 160, the ball is outside the field. This is true regardless of 
    ; if the ball went out to the left or right! 8-bit unsigned numbers, am I right? Or left?
    
    cp 160
    ret c 
    
    ; If we get here, it means the ball was indeed outside 
    ; Now we need to know which side. We can just look at the ball's direction 
    
    ld a, [BALL_DIRECTION]
    cp 128
    jr nc, .leftSide

.rightSide:
    ; Increase left player's score 
    ld a, [LEFT_SCORE]
    add a, 1 ; Since it's in decimal format, we can't use inc/dec and we need to remember to use daa     
    daa 
    ld [LEFT_SCORE], a 
    
    ; Show some supportive text 
    ld c, 0 
    ld b, 0
    ld hl, SupportiveText
    ld d, 3
    ld e, 16
    call RenderTextToEnd
    
    
    jr .end 
    
.leftSide:
    ; Increase right player's score 
    ld a, [RIGHT_SCORE]
    add 1
    daa 
    ld [RIGHT_SCORE], a 
    
    ; Show taunting text 
    ld c, 0 
    ld b, 0
    ld hl, TauntingText
    ld d, 3
    ld e, 16
    call RenderTextToEnd
    
    
.end:
    ; Place ball at initial position 
    
    ; X 
    ld a, 80
    ld [BALL_POSITION], a 
    
    ; Y 
    ld a, 72
    ld [BALL_POSITION+1], a 
    
    
    REPT 15
    ld a, 1 
    call UpdateMusic
    
    halt 
    nop 
    ENDR
    
    ; Check if right player's score is 10. If so, the game is over 
    ld a, [RIGHT_SCORE]
    cp $10
    jr z, .gameOver
    
    ret 
    
.gameOver:
    call DrawScore 

    ld hl, GameOverText
    ld b, 0 ; End character 
    ld c, 0 ; Draw to background
    ld d, 1 ; X position 
    ld e, 20 ; Y position 
    call RenderTextToEnd

    ; Hide sprites 
    ld   hl, SPRITES_START
    ld   bc, SPRITES_LENGTH
    xor a 
    call mSetVRAM 
    
    ; Scroll the screen down a bit
    ld c, 100
.scrollDown:
    ld a, [SCROLL_Y]
    inc a 
    ld [SCROLL_Y], a 
    
    call ShorterWait
    
    dec c 
    ld a, c 
    cp 0 
    jr nz, .scrollDown
    
    ; Now remove the first few lines of tiles so that they don't become visible when we scroll too far down 
    ld a, 1 
    ld hl, BACKGROUND_MAPDATA_START
    ld bc, 32*4
    call mSetVRAM
    
    ; Scroll down a bit more 
    ld c, 40 
.scrollDown2:
    ld a, [SCROLL_Y]
    inc a 
    ld [SCROLL_Y], a 
    
    call ShorterWait
    
    dec c 
    ld a, c 
    cp 0 
    jr nz, .scrollDown2
    
    call ShortWait
    call ShortWait
    call ShortWait
    
    ; Compare player's score with high score and save new high score if it's higher 
    ld a, [LEFT_SCORE]
    ld b, a 
    
    call EnableSaveData
    ld a, [SRAM_HIGH_SCORE]
    
    cp b 
    call c, .newHighScore
    
    call DisableSaveData
    
    ; Resets the game  
    jp GingerBreadBegin 
    
; Local function for writing high score to SRAM     
.newHighScore:
    ld a, b 
    ld [SRAM_HIGH_SCORE], a 
    ret 

ShorterWait:
    ld b, 4 
.wait:
    ld a, 1 
    call UpdateMusic

    halt 
    nop 
    
    dec b 
    ld a, b 
    cp 0 
    jr nz, .wait 
    
    ret 
    
; Modifies AF and BC and DE  
UpdateBall:
    ; Store dx in B, and add to ball x
    ld a, [BALL_DIRECTION]
    ld b, a 
    ld a, [BALL_POSITION]
    add b 
    ld [BALL_POSITION], a 
    
    ; Store dy in C, and add to ball y 
    ld a, [BALL_DIRECTION+1]
    ld c, a 
    ld a, [BALL_POSITION+1]
    add c 
    ld [BALL_POSITION+1], a 
    
    ; Check if ball collides with ceiling, if so reverse dy
    ld a, [BALL_POSITION+1]
    cp 24
    call c, ReverseBallDY
    
    ; Same but for the floor
    ld a, [BALL_POSITION+1]
    cp 144
    call nc, ReverseBallDY
    
    ; Check if ball is outside the playing field 
    call CheckBallOut
    
    ; Check collision with paddles 
    call CheckCollisionRightPaddle
    call CheckCollisionLeftPaddle
    
    ret 

RightPaddleStartMovingDown:
    ld a, 1 
    ld [RIGHT_PADDLE_DIRECTION], a 
    ret 
    
RightPaddleStartMovingUp:
    xor a 
    ld [RIGHT_PADDLE_DIRECTION], a
    ret 
    
UpdateRightPaddleDirection:    
    ; Reset check counter
    xor a 
    ld [RIGHT_PADDLE_CHECK_TIME], a 

    ; Compare ball's and right paddle's y values and move paddle accordingly
    ld a, [BALL_POSITION+1]
    sub 8 ; because paddle is taller than ball 
    ld b, a 
    ld a, [RIGHT_PADDLE_POSITION+1]
    push af 
    push bc 
    cp b
    call nc, RightPaddleStartMovingUp
    pop bc 
    pop af 
    cp b 
    call c, RightPaddleStartMovingDown
    
    ret 
    
UpdateRightPaddle:
    ld a, [RIGHT_PADDLE_DIRECTION] ; 0 means up, 1 means down 
    cp 0 
    jr z, .moveUp

.moveDown:
    call MoveRightPaddleDown
    ret

.moveUp:
    call MoveRightPaddleUp
    ret 
    
GameLoop:
    call DrawLeftPaddle
    call DrawRightPaddle
    call DrawBall
    call DrawScore 

    ld a, 1 
    call UpdateMusic
    
    halt 
    nop 
    
    call ReadKeys
    push af ; Store key status so it can be used twice 
    and KEY_UP
    cp 0 
    call nz, MoveLeftPaddleUp
    pop af 
    and KEY_DOWN
    cp 0 
    call nz, MoveLeftPaddleDown
    
    call UpdateBall
    
    ld a, [RIGHT_PADDLE_CHECK_TIME]
    inc a 
    ld [RIGHT_PADDLE_CHECK_TIME], a 
    cp RIGHT_PADDLE_CHECK_FREQUENCY
    call z, UpdateRightPaddleDirection 
    
    call UpdateRightPaddle
    
    jp GameLoop 
    