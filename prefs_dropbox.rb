class PrefsDropbox <  OSX::NSView
  def initWithFrame(frame)
    super_initWithFrame(frame)
    registerForDraggedTypes_ [OSX::NSFilenamesPboardType]
    return self
  end

  def drawRect(rect) end
  
  def draggingEntered(sender)
    mask = sender.draggingSourceOperationMask
    pboard = sender.draggingPasteboard
    if mask and OSX::NSDragOperationLink
      return OSX::NSDragOperationLink
    elsif mask and OSX::NSDragOperationCopy
      return OSX::NSDragOperationCopy
    end
    OSX::NSDragOperationNone
  end
  
  def performDragOperation(sender)
    mask = sender.draggingSourceOperationMask
    pboard = sender.draggingPasteboard
    files = pboard.propertyListForType OSX::NSFilenamesPboardType
    if files.length == 1 and files[0].to_s.match(/\.app$/)
      draw_icon files[0].to_s
      @app = files[0].to_s
    end
  end

  def draw_icon(path)
    icon = OSX::NSWorkspace.sharedWorkspace.iconForFile path
    icon.setFlipped true
    rect = OSX::NSRect.new 475, 265, 128, 128
    icon.drawInRect_fromRect_operation_fraction rect, OSX::NSZeroRect, OSX::NSCompositeSourceOver, 1.0
  end
end
