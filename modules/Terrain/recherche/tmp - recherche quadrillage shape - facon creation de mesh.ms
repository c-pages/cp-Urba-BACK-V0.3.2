geo = str_geometrie ()


pts = for i = 1 to numKnots $Rectangle002 collect  getKnotPoint $Rectangle002 1  i
geo.vider  		cible:$plane001
geo.face pts 	cible:$plane001
select $plane001
























