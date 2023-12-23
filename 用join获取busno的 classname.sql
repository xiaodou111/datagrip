SELECT s.busno,tb.classname 
FROM s_busi s 
LEFT join t_busno_class_set ts ON s.busno=ts.busno AND ts.CLASSGROUPNO='303'
LEFT join t_busno_class_base tb ON ts.CLASSGROUPNO=tb.classgroupno AND tb.classgroupno='303' AND ts.classcode=tb.classcode
WHERE s.busno=84001
