/*
Cool Bricks (GBC) Autosplitter
Authors: Roddy and Burndi
Date: September 8, 2023

Compatibility:
    - VisualBoyAdvance-M 2.1.5, 2.1.6
    - BizHawk 2.8 ( outdated! add support to 2.9.1 )

shoutouts to katzi
*/

state("VisualBoyAdvance-M", "vba_2.1.5") { // Version 2.1.5
    byte RAM_START  : "visualboyadvance-m.exe", 0x02758E30, 0x00; // RAM at $C000
    byte Level      : "visualboyadvance-m.exe", 0x02758E38, 0xCFE;  // WRAM at $D000 + $0CFE
    byte end_screen : "visualboyadvance-m.exe", 0x02758E38, 0xCFF;  // set to 0E on congratulations screen
    byte checkpoint : "visualboyadvance-m.exe", 0x02758E38, 0xD00;  // checkpoint
    byte start_game : "visualboyadvance-m.exe", 0x02758E38, 0xD4D;  // pressed on start game
}

state("VisualBoyAdvance-M", "vba_2.1.6") { // Version 2.1.6
    byte RAM_START  : "visualboyadvance-m.exe", 0x26AA270, 0x00; // RAM at $C000
    byte Level      : "visualboyadvance-m.exe", 0x26AA278, 0xCFE;  // WRAM at $D000 + $0CFE
    byte end_screen : "visualboyadvance-m.exe", 0x26AA278, 0xCFF;  // set to 0E on congratulations screen
    byte checkpoint : "visualboyadvance-m.exe", 0x26AA278, 0xD00;  // checkpoint
    byte start_game : "visualboyadvance-m.exe", 0x26AA278, 0xD4D;  // pressed on start game
}
// 0x26AA210

state("EmuHawk", "eh_2.8") {
    byte RAM_START  : "libgambatte.DLL", 0x77050, 0x128, 0x0000; // start of RAM $C000
    byte Level      : "libgambatte.dll", 0x77050, 0x128, 0x1CFE; // current level of the set
    byte end_screen : "libgambatte.dll", 0x77050, 0x128, 0x1CFF; // congratulations screen (set to 0E)
    byte checkpoint : "libgambatte.dll", 0x77050, 0x128, 0x1D00; // checkpoint flag
    byte start_game : "libgambatte.dll", 0x77050, 0x128, 0x1D4D; // pressed on start game (set to DC)
}

state("EmuHawk", "eh_2.9.1") {
    byte RAM_START : "libgambatte.DLL", 0x77050, 0x128, 0x0000; // start of RAM $C000
}

// to do: Support to EmuHawk 2.9.1 (most recent version. libgambatte isn't cooperating for some reason.)

startup {
    settings.Add("perLevel", false, "Split per Level");
}

init {
    // Debug: Print program size in case a new emulator version is released:
    // print(modules.First().ModuleMemorySize.ToString());

    vars.AlreadySplit = false;
    vars.LevelRecord = 1;

    if (game.ProcessName.ToString().ToLower() == "visualboyadvance-m") {
        switch(modules.First().ModuleMemorySize) {
            case 71827456:
                version = "vba_2.1.4";
            break;
            case 49872896:
                version = "vba_2.1.5";
            break;
            case 49053696:
                version = "vba_2.1.6";
            break;
        }
    }
    if (game.ProcessName.ToString().ToLower() == "emuhawk") {
        switch(modules.First().ModuleMemorySize) {
            case 4571136:
                version = "eh_2.8";
            break;
            case 4726784:
                version = "eh_2.9.1";
                var errorMessage = MessageBox.Show(
                    "BizHawk 2.9.1 isn't supported yet. It is coming in a future update.\n"+
                    "Please downgrade to version 2.8 if you want to use the autosplitter.\n",
                    "Cool Bricks Autosplitter: No support error",	// Window title
                MessageBoxButtons.OK, MessageBoxIcon.Exclamation); // Window buttons
            break;
        }
    }
}

update {
    if (current.checkpoint == 0 && vars.AlreadySplit == true) {
        vars.AlreadySplit = false;
    }
}

start {
    vars.LevelRecord = 1;
    return current.end_screen != 0x0E && current.Level == 0 && current.start_game == 0xDC;
}

split {
    if (settings["perLevel"]) {
        if (current.Level > vars.LevelRecord) {
            vars.LevelRecord = current.Level;
            return true;
        }
    }

    // Split on the end of every 4 level set
    if (current.Level == 0 && current.checkpoint == 1 && vars.AlreadySplit == false) {
        vars.AlreadySplit = true;
        vars.LevelRecord = 1;
        return true;
    }

    // spam split on end screen
    if (current.end_screen == 0x0E) {
        return true;
    }
}