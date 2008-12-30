=begin
Copyright (c) 2008 Hans Engel
See the file LICENSE for licensing details.
=end

class PreferencesController < OSX::NSObject
  ib_outlet :applications_table, :path_control, :directions
  def applicationDidFinishLaunching(notification)
    load_prefs
    @keys = nil
    @app = nil
    @table_rows = ['Menu', 'Play / Pause', 'Previous Track', 'Next Track', 'Volume Down', 'Volume Up']
    @template = {'Menu' => '', 'Play / Pause' => '', 'Previous Track' => '', 'Next Track' => '', 'Volume Down' => '', 'Volume Up' => ''}
  end
  
  def load_prefs
    @defaults = OSX::NSUserDefaults.standardUserDefaults
    @dictionary = @defaults.objectForKey 'commands'
    if @dictionary.nil?
      @defaults.setObject_forKey Hash.new, 'commands'
      @dictionary = @defaults.objectForKey 'commands'
    end
  end

  def pathControl_acceptDrop(control, drop)
    files = drop.draggingPasteboard.propertyListForType OSX::NSFilenamesPboardType
    if files.length == 1
      @app = File.basename files[0].to_s
      build_path_cell_array files[0].to_s
      @keys = @dictionary.objectForKey File.basename(files[0].to_s)
      unless @keys
        @dictionary.setObject_forKey @template, File.basename(files[0].to_s)
        @keys = @dictionary.objectForKey File.basename(files[0].to_s)
      end
      @applications_table.reloadData
      @applications_table.setEnabled true
      @directions.setObjectValue 'Double-click on the second column for each row to change which keypresses should be sent to the application.'
    end
  end

  def build_path_cell_array(path)
    segs = path.split '/'
    segs.delete_at 0
    cells = []
    segs.each_with_index do |seg, idx|
      path = ''
      (0..idx).each do |num|
        path += '/' + segs[num]
      end
      cell = OSX::NSPathComponentCell.new
      cell.setURL OSX::NSURL.alloc.initWithString(path)
      cell.setImage OSX::NSWorkspace.sharedWorkspace.iconForFile(path)
      segs[idx].gsub! /\.app$/, '' if idx + 1 == segs.length
      cell.setObjectValue segs[idx]
      cells << cell
    end
    @path_control.setPathComponentCells cells
  end

  def numberOfRowsInTableView(table)
    @keys.count rescue 0
  end
  def tableView_objectValueForTableColumn_row(table, column, row)
    column = column.headerCell.stringValue.to_s unless column.is_a? String
    case column
    when 'Button'
      return @table_rows[row]
    when 'Assigned Hotkey'
      return @keys[@table_rows[row]]
    end
  end
  def tableView_setObjectValue_forTableColumn_row(table, value, column, row)
    @keys[@table_rows[row]] = value.to_s
    @dictionary.setObject_forKey @keys, @app
    load_prefs
  end

  def insert_hotkey(sender)
    idx = @applications_table.selectedRowIndexes
    if idx.count == 1
      idx = idx.firstIndex
      content = tableView_objectValueForTableColumn_row @applications_table, 'Assigned Hotkey', idx
      tableView_setObjectValue_forTableColumn_row @applications_table, content + sender.title.to_s, 'Assigned Hotkey', idx
    end
    @applications_table.reloadData
  end
end
