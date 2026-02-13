function love.conf(t)
    t.identity                     = "default"  -- This flag determines the name of the save directory for your game. Note that you can only specify the name, not the location where it will be created: t.identity = "gabe_HL3" -- Correct t.identity = "c:/Users/gabe/HL3" -- Incorrect Alternatively love.filesystem.setIdentity can be used to set the save directory outside of the config file.
    t.appendidentity               = true       -- This flag determines if game directory should be searched first then save directory (true) or otherwise (false)
    t.version                      = "11.5"     -- t.version should be a string, representing the version of LÖVE for which your game was made. It should be formatted as "X.Y.Z" where X is the major release number, Y the minor, and Z the patch level. It allows LÖVE to display a warning if it isn't compatible. Its default is the version of LÖVE running.
    t.console                      = true       -- Determines whether a console should be opened alongside the game window (Windows only) or not. Note: On OSX you can get console output by running LÖVE through the terminal.
    t.accelerometerjoystick        = true       -- Sets whether the device accelerometer on iOS and Android should be exposed as a 3-axis Joystick. Disabling the accelerometer when it's not used may reduce CPU usage.
    t.externalstorage              = true       -- Sets whether files are saved in external storage (true) or internal storage (false) on Android.
    t.gammacorrect                 = true       -- Determines whether gamma-correct rendering is enabled, when the system supports it.

    t.audio.mic                    = true       -- Request microphone permission from the user. When user allows it, love.audio.getRecordingDevices will lists recording devices available. Otherwise, love.audio.getRecordingDevices returns empty table and a message is shown to inform user when called.
    t.audio.mixwithsystem          = true       -- Sets whether background audio / music from other apps should play while LÖVE is open. See love.system.hasBackgroundMusic for more details.

    t.window.title                 = "default"  -- Sets the title of the window the game is in. Alternatively love.window.setTitle can be used to change the window title outside of the config file.
    t.window.icon                  = "default"  -- A filepath to an image to use as the window's icon. Not all operating systems support very large icon images. The icon can also be changed with love.window.setIcon.
    t.window.width                 = nil        -- Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions.
    t.window.height                = nil        -- Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions.
    t.window.borderless            = true       -- Removes all border visuals from the window. Note that the effects may wary between operating systems.
    t.window.resizable             = true       -- If set to true this allows the user to resize the game's window.
    t.window.minwidth              = nil        -- Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight.
    t.window.minheight             = nil        -- Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight.
    t.window.fullscreen            = true       -- Whether to run the game in fullscreen (true) or windowed (false) mode. The fullscreen can also be toggled via love.window.setFullscreen or love.window.setMode.
    t.window.fullscreentype        = "default"  -- Specifies the type of fullscreen mode to use (normal or desktop). Generally the desktop is recommended, as it is less restrictive than normal mode on some operating systems.
    t.window.usedpiscale           = true       -- Sets whetever to enable or disable automatic DPI scaling.
    t.window.vsync                 = nil        -- Enables or deactivates vertical synchronization. Vsync tries to keep the game at a steady framerate and can prevent issues like screen tearing. It is recommended to keep vsync activated if you don't know about the possible implications of turning it off. Before LÖVE 11.0, this value was boolean (true or false). Since LÖVE 11.0, this value is number (1 to enable vsync, 0 to disable vsync, -1 to use adaptive vsync when supported). Note that in iOS, vertical synchronization is always enabled and cannot be changed.
    t.window.depth                 = nil        -- The number of bits per sample in the depth buffer (16/24/32, default nil)
    t.window.stencil               = nil        -- Then number of bits per sample in the depth buffer (generally 8, default nil)
    t.window.msaa                  = nil        -- The number of samples to use with multi-sampled antialiasing.
    t.window.display               = nil        -- The index of the display to show the window in, if multiple monitors are available.
    t.window.highdpi               = true       -- See love.window.getPixelScale, love.window.toPixels, and love.window.fromPixels. It is recommended to keep this option disabled if you can't test your game on a Mac or iOS system with a Retina display, because code will need tweaking to make sure things look correct.
    t.window.x                     = nil        -- Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly.
    t.window.y                     = nil        -- Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly.

    t.modules.audio                = true       -- Enable the audio module.
    t.modules.event                = true       -- Enable the event module.
    t.modules.graphics             = true       -- Enable the graphics module.
    t.modules.image                = true       -- Enable the image module.
    t.modules.joystick             = true       -- Enable the joystick module.
    t.modules.keyboard             = true       -- Enable the keyboard module.
    t.modules.math                 = true       -- Enable the math module.
    t.modules.mouse                = true       -- Enable the mouse module.
    t.modules.physics              = true       -- Enable the physics module.
    t.modules.sound                = true       -- Enable the sound module.
    t.modules.system               = true       -- Enable the system module.
    t.modules.timer                = true       -- Enable the timer module.
    t.modules.touch                = true       -- Enable the touch module.
    t.modules.video                = true       -- Enable the video module.
    t.modules.window               = true       -- Enable the window module.
    t.modules.thread               = true       -- Enable the thread module.
end
