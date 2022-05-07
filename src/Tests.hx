package;

import GameState.Direction;

class TestDat {
    public var startState:String;
    public var inputString:String;
    public var endState:String;
    public function new(startState:String, inputString:String, endState:String) {
        this.startState = startState;
        this.inputString = inputString;
        this.endState = endState;
    }

    public function runTest():Bool{
        var gamestate = GameState.FromString(startState);

        for (i in 0...inputString.length){
            var input_char=inputString.charAt(i);
            if (input_char==" "){
                continue;
            }
            var input:Direction = ["N","E","S","W"].indexOf(input_char);
            gamestate.tryMove(gamestate.p, input, true, true);
        }

        var calculated_endState = gamestate.ToStringTrace();
        var success = calculated_endState == endState;
        if (success==false){
            var endmessage:String="";
            endmessage+="FAILED TEST\n";
            endmessage+="LEVELDAT\n";
            endmessage+=startState+"\n";
            endmessage+="INPUT\n";   
            trace(inputString);
            endmessage+="EXPECTED ENDSTATE\n";   
            endmessage+=endState+"\n";
            endmessage+="CALCULATED ENDSTATE\n";
            endmessage+=calculated_endState;
            trace(endmessage);
        }
        return success;
    }

}

class Tests {
    public static var tests:Array<TestDat> = [
        new TestDat("cy9:GameStatey4:dirsazi1i2i3hy5:Tilesaancy4:Tiley14:ramp_directioni-1y6:heighti20y8:altitudezy1:yi1y1:xi1gcR3R4i-1R5i20R6zR7i1R8i2gcR3R4i-1R5i20R6zR7i1R8i3gncR3R4i-1R5i20R6zR7i1R8i5gcR3R4i-1R5i20R6zR7i1R8i6gcR3R4i-1R5i20R6zR7i1R8i7gnhacR3R4i-1R5i20R6zR7i2R8zgcR3R4i-1R5i20R6zR7i2R8i1gcR3R4i-1R5i12R6zR7i2R8i2gcR3R4i-1R5i12R6zR7i2R8i3gcR3R4i-1R5i12R6zR7i2R8i4gcR3R4i-1R5i12R6zR7i2R8i5gcR3R4i-1R5i12R6zR7i2R8i6gcR3R4i-1R5i20R6zR7i2R8i7gcR3R4i-1R5i20R6zR7i2R8i8ghacR3R4i-1R5i20R6zR7i3R8zgcR3R4i-1R5i20R6zR7i3R8i1gcR3R4i-1R5i12R6zR7i3R8i2gcR3R4zR5i12R6zR7i3R8i3gcR3R4i-1R5i12R6zR7i3R8i4gcR3R4i3R5i12R6zR7i3R8i5gcR3R4zR5i12R6zR7i3R8i6gcR3R4i-1R5i20R6zR7i3R8i7gcR3R4i-1R5i20R6zR7i3R8i8ghacR3R4i-1R5i20R6zR7i4R8zgcR3R4i-1R5i20R6zR7i4R8i1gcR3R4i-1R5i12R6zR7i4R8i2gcR3R4zR5i10R6zR7i4R8i3gcR3R4zR5i10R6zR7i4R8i4gcR3R4i-1R5i8R6zR7i4R8i5gcR3R4i-1R5i10R6zR7i4R8i6gcR3R4i-1R5i20R6zR7i4R8i7gcR3R4i-1R5i20R6zR7i4R8i8ghacR3R4zR5i8R6zR7i5R8zgcR3R4i-1R5i6R6zR7i5R8i1gcR3R4i-1R5i6R6zR7i5R8i2gcR3R4i1R5i8R6zR7i5R8i3gcR3R4i3R5i10R6zR7i5R8i4gcR3R4i3R5i8R6zR7i5R8i5gcR3R4i-1R5i6R6zR7i5R8i6gcR3R4i-1R5i6R6zR7i5R8i7gcR3R4i-1R5i6R6zR7i5R8i8ghacR3R4i3R5i8R6zR7i6R8zgcR3R4i-1R5i6R6zR7i6R8i1gcR3R4i2R5i8R6zR7i6R8i2gcR3R4i-1R5i6R6zR7i6R8i3gcR3R4zR5i8R6zR7i6R8i4gcR3R4i-1R5i6R6zR7i6R8i5gcR3R4i-1R5i6R6zR7i6R8i6gcR3R4i-1R5i6R6zR7i6R8i7gcR3R4i-1R5i6R6zR7i6R8i8ghacR3R4i2R5i8R6zR7i7R8zgcR3R4i-1R5i8R6zR7i7R8i1gcR3R4i3R5i8R6zR7i7R8i2gcR3R4i-1R5i6R6zR7i7R8i3gcR3R4i-1R5i6R6zR7i7R8i4gcR3R4i-1R5i6R6zR7i7R8i5gcR3R4i3R5i6R6zR7i7R8i6gcR3R4i-1R5i4R6zR7i7R8i7gcR3R4i-1R5i4R6zR7i7R8i8ghacR3R4i-1R5i4R6zR7i8R8zgcR3R4zR5i8R6zR7i8R8i1gcR3R4zR5i6R6zR7i8R8i2gcR3R4i-1R5i4R6zR7i8R8i3gcR3R4i-1R5i4R6zR7i8R8i4gcR3R4i-1R5i6R6zR7i8R8i5gcR3R4i-1R5i4R6zR7i8R8i6gcR3R4i-1R5i4R6zR7i8R8i7gcR3R4i2R5i6R6zR7i8R8i8ghacR3R4i-1R5i4R6zR7i9R8zgcR3R4i-1R5i4R6zR7i9R8i1gcR3R4zR5i6R6zR7i9R8i2gcR3R4i-1R5i4R6zR7i9R8i3gcR3R4i1R5i6R6zR7i9R8i4gcR3R4i-1R5i6R6zR7i9R8i5gcR3R4i3R5i6R6zR7i9R8i6gcR3R4i-1R5i4R6zR7i9R8i7gcR3R4i-1R5i6R6zR7i9R8i8ghancR3R4i-1R5i4R6zR7i9R8i1gcR3R4i-1R5i4R6zR7i9R8i2gcR3R4i-1R5i4R6zR7i9R8i3gu5hhy2:c2cy6:Entityy12:fromaltitudei4y5:fromyi7y5:fromxi6R5i4R6i4R7i7R8i6y3:diri2y7:fromdiri2gy1:pcR10R11i5R12i7R13i2R5i2R6i5R7i7R8i2R14i2R15i2gy2:c1cR10R11i6R12i5R13i6R5i4R6i6R7i5R8i6R14i2R15i2gy6:pillowcR10R11i5R12i8R13i2R5i2R6i5R7i8R8i2R14i2R15i2gg", "EWEW","3,7,4,6,5,6,6,7,4"),
        new TestDat("cy9:GameStatey4:dirsazi1i2i3hy5:Tilesaancy4:Tiley14:ramp_directioni-1y6:heighti20y8:altitudezy1:yi1y1:xi1gcR3R4i-1R5i20R6zR7i1R8i2gcR3R4i-1R5i20R6zR7i1R8i3gncR3R4i-1R5i20R6zR7i1R8i5gcR3R4i-1R5i20R6zR7i1R8i6gcR3R4i-1R5i20R6zR7i1R8i7gnhacR3R4i-1R5i20R6zR7i2R8zgcR3R4i-1R5i20R6zR7i2R8i1gcR3R4i-1R5i12R6zR7i2R8i2gcR3R4i-1R5i12R6zR7i2R8i3gcR3R4i-1R5i12R6zR7i2R8i4gcR3R4i-1R5i12R6zR7i2R8i5gcR3R4i-1R5i12R6zR7i2R8i6gcR3R4i-1R5i20R6zR7i2R8i7gcR3R4i-1R5i20R6zR7i2R8i8ghacR3R4i-1R5i20R6zR7i3R8zgcR3R4i-1R5i20R6zR7i3R8i1gcR3R4i-1R5i12R6zR7i3R8i2gcR3R4zR5i12R6zR7i3R8i3gcR3R4i-1R5i12R6zR7i3R8i4gcR3R4i3R5i12R6zR7i3R8i5gcR3R4zR5i12R6zR7i3R8i6gcR3R4i-1R5i20R6zR7i3R8i7gcR3R4i-1R5i20R6zR7i3R8i8ghacR3R4i-1R5i20R6zR7i4R8zgcR3R4i-1R5i20R6zR7i4R8i1gcR3R4i-1R5i12R6zR7i4R8i2gcR3R4zR5i10R6zR7i4R8i3gcR3R4zR5i10R6zR7i4R8i4gcR3R4i-1R5i8R6zR7i4R8i5gcR3R4i-1R5i10R6zR7i4R8i6gcR3R4i-1R5i20R6zR7i4R8i7gcR3R4i-1R5i20R6zR7i4R8i8ghacR3R4zR5i8R6zR7i5R8zgcR3R4i-1R5i6R6zR7i5R8i1gcR3R4i-1R5i6R6zR7i5R8i2gcR3R4i1R5i8R6zR7i5R8i3gcR3R4i3R5i10R6zR7i5R8i4gcR3R4i3R5i8R6zR7i5R8i5gcR3R4i-1R5i6R6zR7i5R8i6gcR3R4i-1R5i6R6zR7i5R8i7gcR3R4i-1R5i6R6zR7i5R8i8ghacR3R4i3R5i8R6zR7i6R8zgcR3R4i-1R5i6R6zR7i6R8i1gcR3R4i2R5i8R6zR7i6R8i2gcR3R4i-1R5i6R6zR7i6R8i3gcR3R4zR5i8R6zR7i6R8i4gcR3R4i-1R5i6R6zR7i6R8i5gcR3R4i-1R5i6R6zR7i6R8i6gcR3R4i-1R5i6R6zR7i6R8i7gcR3R4i-1R5i6R6zR7i6R8i8ghacR3R4i2R5i8R6zR7i7R8zgcR3R4i-1R5i8R6zR7i7R8i1gcR3R4i3R5i8R6zR7i7R8i2gcR3R4i-1R5i6R6zR7i7R8i3gcR3R4i-1R5i6R6zR7i7R8i4gcR3R4i-1R5i6R6zR7i7R8i5gcR3R4i3R5i6R6zR7i7R8i6gcR3R4i-1R5i4R6zR7i7R8i7gcR3R4i-1R5i4R6zR7i7R8i8ghacR3R4i-1R5i4R6zR7i8R8zgcR3R4zR5i8R6zR7i8R8i1gcR3R4zR5i6R6zR7i8R8i2gcR3R4i-1R5i4R6zR7i8R8i3gcR3R4i-1R5i4R6zR7i8R8i4gcR3R4i-1R5i6R6zR7i8R8i5gcR3R4i-1R5i4R6zR7i8R8i6gcR3R4i-1R5i4R6zR7i8R8i7gcR3R4i2R5i6R6zR7i8R8i8ghacR3R4i-1R5i4R6zR7i9R8zgcR3R4i-1R5i4R6zR7i9R8i1gcR3R4zR5i6R6zR7i9R8i2gcR3R4i-1R5i4R6zR7i9R8i3gcR3R4i1R5i6R6zR7i9R8i4gcR3R4i-1R5i6R6zR7i9R8i5gcR3R4i3R5i6R6zR7i9R8i6gcR3R4i-1R5i4R6zR7i9R8i7gcR3R4i-1R5i6R6zR7i9R8i8ghancR3R4i-1R5i4R6zR7i9R8i1gcR3R4i-1R5i4R6zR7i9R8i2gcR3R4i-1R5i4R6zR7i9R8i3gu5hhy2:c2cy6:Entityy12:fromaltitudei4y5:fromyi7y5:fromxi6R5i4R6i4R7i7R8i6y3:diri2y7:fromdiri2gy1:pcR10R11i5R12i8R13i4R5i2R6i5R7i8R8i4R14i1R15i1gy2:c1cR10R11i6R12i5R13i6R5i4R6i6R7i5R8i6R14i2R15i2gy6:pillowcR10R11i5R12i8R13i2R5i2R6i5R7i8R8i2R14i2R15i2gg", "WSWN NNWN ES","2,7,5,6,5,6,6,7,4"),
    ];
}