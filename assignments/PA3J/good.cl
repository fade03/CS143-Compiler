class A {
};

Class BB__ inherits A {
};


class Cons inherits List {
    xcar : Int;
    xcdr : List;

    isNil() : Bool { false };

    init(hd : Int, tl : List) : Cons { 
        {
            xcar <- hd;
            xcdr <- tl;
            false;
            self;
            if true then 1 else "1" fi;
            (5);
            abord();
            abord(1);
        }
    };
};