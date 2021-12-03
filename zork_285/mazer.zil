;"MAZER  - MAZER.78 Jun 30, 1977
  The MDL version of this file contains definitions and types for directions
  and exits. In ZIL this is mostly built into to language andisn't needed."

;"Matches a noun (PS?OBJECT) from the vocabulary with its object.
  This is done by looping through all objects (not rooms) and
  search for the word among the synonyms."
<ROUTINE FIND-OBJ (W "AUX" (OBJ <>) L)
    <DO (I 1 ,LAST-OBJECT)
        <COND (<AND <NOT <IN? .I ,ROOMS>> <GETPT .I ,P?SYNONYM>>    ;"Not a room and have synonym-property"
                <SET L </ <PTSIZE <GETPT .I ,P?SYNONYM>> 2>>        ;"Number of synonyms = length / 2"
                <COND (<INTBL? .W <GETPT .I ,P?SYNONYM> .L> 
                        <RETURN .I>)>)>>
    <RETURN <>>>  ;"No match"

