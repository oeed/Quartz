
class "DestinationView" extends "View" implements "IDragDropDestination" {
    rectangle = false;
    row = 0;
    dropStyle = DragDropManager.dropStyles.SHRINK;
}


function DestinationView:initialiseCanvas()
    self:super()
    self.canvas.fillColour = colours.white
    self.rectangle = self.canvas:insert( Rectangle(1,1,80,80) )
    self.rectangle.outlineColour = colours.blue
    -- self.rectangle.outlineColour = colours.green
    self.row = 0

end

function DestinationView:canAcceptDragDrop( data )
    return true
end

function DestinationView:dragDropEntered( data, dragView )
    self:animate( "row", 3, 0.3 )
end

function DestinationView.row:set(row)
    self.row = row
    self.rectangle.outlineWidth = row
end

function DestinationView:dragDropExited( data, dragView )
    self:animate( "row", 0, 0.3 )
end

function DestinationView:dragDropMoved( data, dragView )
end

function DestinationView:dragDropDropped( data )

end
