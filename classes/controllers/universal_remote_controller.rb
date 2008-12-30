=begin
Copyright (c) 2008 Hans Engel
See the file LICENSE for licensing details.
=end

require 'osx/cocoa'
OSX.ns_import 'AppleRemote'

class UniversalRemoteController < OSX::NSObject
  ib_outlet :prefs
  addRubyMethod_withType 'sendRemoteButtonEvent:pressedDown:remoteControl:', 'v@:ii@'

  def initialize(*args)
    super args
    @dictionary = OSX::NSUserDefaults.standardUserDefaults.objectForKey 'commands'
    @codes = {
      2 => 'Volume Up',
      4 => 'Volume Down',
      8 => 'Menu',
      16 => 'Play / Pause',
      32 => 'Next Track',
      64 => 'Previous Track'}
  end
  
  def sendRemoteButtonEvent_pressedDown_remoteControl(buttonIdentifier, pressedDown, remoteControl)
    if pressedDown == 1
      app = OSX::NSWorkspace.sharedWorkspace.activeApplication
      commands = @dictionary.objectForKey File.basename(app['NSApplicationPath'])
      unless commands.nil?
        keystroke = commands[@codes[buttonIdentifier]]
        keystroke, modifiers = parse_keystroke keystroke
        script = <<EOT
tell application "#{app['NSApplicationName'].to_s}"
  activate
  tell application "System Events" to keystroke "#{keystroke}" using {#{modifiers}}
end tell
EOT
        OSX::NSAppleScript.alloc.initWithSource(script).executeAndReturnError OSX::NSDictionary.dictionary
      end
    end
  end

  def parse_keystroke(keystroke)
    modifiers = []
    keystroke = keystroke.to_s
    if keystroke.match(/⌘/)
      modifiers << 'command down'
      keystroke.gsub! /⌘/, ''
    end
    if keystroke.match(/⌥/)
      modifiers << 'option down'
      keystroke.gsub! /⌥/, ''
    end
    if keystroke.match(/⇧/)
      modifiers << 'shift down'
      keystroke.gsub! /⇧/, ''
    end
    if keystroke.match(/[⌃^]/)
      modifiers << 'control down'
      keystroke.gsub! /[⌃^]/, ''
    end
    [keystroke.downcase, modifiers.join(', ')]
  end
end

d = UniversalRemoteController.alloc.init
a = OSX::AppleRemote.alloc.initWithDelegate_ d
a.startListening 0
