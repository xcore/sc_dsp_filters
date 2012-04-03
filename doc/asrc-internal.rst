Internals of module_asrc
========================

Belwo we describe the ASRC implementation. THe basic sequence of operations
is as follows:

* Recent samples are stored in a circular buffer.

* When a request is made to delete or insert a sample, a low pass FIR is
  used to interpolate

* Between each two samples in a series of 16 samples, 7 zeros are inserted.
  Then from sample 5 to 13, the FIR is then applied in order to compute
  intermediate samples.

* Computations are not performed on the zero samples.

This is shown graphically below Each line starting with B........B..... etc
indicates the input samples with each '.' representing a 0 sample, and B,
0, 1, 2, 3, ... the sample values.
The markers "NRP" and "WP" indicate the normal read point and write point.
The line below with the ....X.... indicates where the subsapmpling takes
place. Finally, the line with ----=--- shows the place of the FIR, with the
'=' symbols representing the zero crossings of the FIR, and the '+' the
center.

It helped me :)

Deleting a sample
-----------------

The code is::

  Step 0: no FIR - prior to delete
  
                                NRP                                              WP
  .......B.......B.......B.......B.......0.......1.......2.......3.......4.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
  Step 1: only advance WP as normal - do not return points
  
                                        NRP                                              WP
  .......B.......B.......B.......B.......0.......1.......2.......3.......4.......5.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
  Step 2: 8 sample active out of 65 tap FIR, start from 7 for WP-10:
  
                                                NRP                                              WP
          =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... .......B.......B.......B.......0.......1.......2.......3.......4.......5.......6.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
  Step 3: 8 sample active out of 65 tap FIR, start from 6 for WP-10:
  
                                                        NRP                                              WP
                   =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... ....... .......B.......B.......0.......1.......2.......3.......4.......5.......6.......7.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  ...
  
  Step 7: 8 sample active out of 65 tap FIR, start from 2 for WP-10:
  
                                                                                        NRP                                              WP
                                                       =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... ....... ....... ....... ....... ....... .......2.......3.......4.......5.......6.......7.......8.......9.......A.......B.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
  Step 8: 8 sample active out of 65 tap FIR, start from 1 for WP-10:
  
                                                                                                NRP                                              WP
                                                                =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... ....... ....... ....... ....... ....... ....... .......3.......4.......5.......6.......7.......8.......9.......A.......B.......C.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
  Step 9: back to normal:
  
                                                                                                        NRP                                              WP
  ....... ....... ....... ....... ....... ....... ....... .......3.......4.......5.......6.......7.......8.......9.......A.......B.......C.......D.......-
                          .......X........X........X........X........X........X........X........X........X.........
  
  
Inserting a sample
------------------
  
The code is::
  
  Step 0: no FIR - prior to insert
  
                                NRP                                              WP
  .......B.......B.......B.......B.......0.......1.......2.......3.......4.......-
  
  
  Step 1: do not advance WP, return one sample ahead of normal read point
  relative to non advanced WP:
  
                                NRP                                              WP
         =-------=-------=-------=-------+-------=-------=-------=-------=
  .......B.......B.......B.......B.......0.......1.......2.......3.......4.......-
                                  .......X......X......X......X......X......X......X......X......X...............
  
  
  Step 2: 8 sample active out of 65 tap FIR, start from 1 on WP-9:
  
                                        NRP                                              WP
                =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... .......B.......B.......B.......0.......1.......2.......3.......4.......5.......-
                                  .......X......X......X......X......X......X......X......X......X...............
  
  
  Step 3: 8 sample active out of 65 tap FIR, start from 2 on WP-9:
  
                                                NRP                                              WP
                       =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... ....... .......B.......B.......0.......1.......2.......3.......4.......5.......6.......-
                                  .......X......X......X......X......X......X......X......X......X...............
  
  ...
  
  
  Step 8: 8 sample active out of 65 tap FIR, start from 7 on WP-9:
  
                                                                                        NRP                                              WP
                                                          =-------=-------=-------=-------+-------=-------=-------=-------=
  ....... ....... ....... ....... ....... ....... ....... .......3.......4.......5.......6.......7.......8.......9.......A.......B.......-
                                  .......X......X......X......X......X......X......X......X......X...............
  
  
  Step 9: return to normal:
  
                                                                                                NRP                                              WP
  ....... ....... ....... ....... ....... ....... ....... .......3.......4.......5.......6.......7.......8.......9.......A.......B.......C.......-
                                  .......X......X......X......X......X......X......X......X......X...............
  
  
