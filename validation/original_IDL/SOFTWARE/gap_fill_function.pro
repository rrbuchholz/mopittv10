;Sara Martinez-Alonso, 09.2011
;
;to fill gaps in an array (e.g., HIPPO P array)

function gap_fill_function, parray

;remove NaN values
good=where(finite(parray, /nan) eq 0)		;non NaN values
bad= where(finite(parray, /nan) eq 1)		;NaN values
aarray=findgen(n_elements(parray))
pg=parray(good)
ag=aarray(good)
pb=parray(bad)
ab=aarray(bad)

;fit polynomy
result=poly_fit (ag, pg, 2, yfit=yg, /double)

;fill gap with calculated values
yb=result(0)+(ab*result(1))+((ab^2)*result(2))
parray(bad)=yb

return, parray

end
