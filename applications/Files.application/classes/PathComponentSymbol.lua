
class PathComponentSymbol extends Symbol {

    static = {
        symbolName = String( "pathComponent" );
        width = Number( 3 );
        height = Number( 5 );
    };

}

function PathComponentSymbol.static:initialise()
    local path = Path( self.width, self.height, 1, 1 )
    path:lineTo( 3, 3 )
    path:lineTo( 1, 5 )
    path:close()
    
    self:super( path )
end
