
class "Test" {
    
    valueOne = false;
    valueTwo = "valueTwo";
    valueThree = false;

}

function Test:test()
    return "true"
end

function Test.valueOne:get()
    return self.valueOne
end

function Test.valueOne:set( value )
    self.valueOne = value:upper()
end
