;Sara Martinez-Alonso, 09.2011
;
;to find gaps larger than a certan delta pressure (deltap)
;between minp and maxp-deltap in an array of HIPPO CO data (corray)
;
;fills missing P values, if necessary
;
;deals with ascending and descending flights (with P and CO stored in
;decreasing and increasing order, respectively) 
;gap=0 means there is no gap
;gap=1 means there is a  gap
;

function gap_function, coarray, parray, minp, maxp, deltap

;if gaps in parray, fill using a degree=2 polynomial fit
nansp=where(finite(parray, /nan), c0)
if c0 gt 0 then parray=gap_fill_function(parray)

;make sure elements in parray are arranged in increasing order
if parray(0) gt parray(n_elements(parray)-1) then begin	;if decreasing P then reverse arrays
  coarray=reverse(coarray)				
  parray=reverse(parray)
endif

gap=0						;by default there is no gap
i=0

;look for gaps between minp and maxp-deltap only
nans=where(finite(coarray, /nan), c1)		;location of NaN values in coarray
if c1 gt 0 then begin				;if there are NaN values
  firstp=minp
  k=abs(parray-firstp)
  nada=min(k,startsearch,/nan)			;minp is in position startsearch
  lastp=maxp-deltap
  k=abs(parray-lastp)
  nada=min(k,endsearch,/nan)			;maxp-deltap is in position endsearch
  nada=where(nans ge startsearch and nans le endsearch, c2)
  if c2 gt 0 then nans=nans(nada)		;chopping off nans located below minp and above maxp-deltap
endif
if c1 eq 0 then c2=0
if c2 gt 0 then begin				;there are NaN values in coarray
  while gap eq 0 and i le c2-1 do begin		;do for each NaN value until a gap is found
    plow=parray(nans(i))			;P value at the beginning of potential gap
    whereisplow=nans(i)
    phigh=plow+deltap				;P value at the end of potential gap
    k=abs(parray-phigh)
    nada=min(k,whereisphigh,/nan)		;whereisphigh is the location in parray of the high end of potential gap 
    if total(coarray(whereisplow:whereisphigh), /nan) eq 0. then begin
      gap=1	;if no CO data in potential gap
    endif
    i=i+1
  endwhile
endif

return, gap

end
