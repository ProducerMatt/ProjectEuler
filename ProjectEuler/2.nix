with (import <nixpkgs> { }); with builtins;

rec {
  isEven = i: (lib.mod i 2) == 0;
  fibEvenIterate = { goal, first ? 1, second ? 2, evenTerms ? [ 2 ] }:
    let
      answer = {
        inherit goal;
        first = second;
        second = first + second;
        evenTerms = if isEven second then
          evenTerms ++ [ second ]
                    else evenTerms;
      }; in
      if answer.second > goal then
        foldl' (x: y: x + y) 0 evenTerms
      else fibEvenIterate answer;
}
