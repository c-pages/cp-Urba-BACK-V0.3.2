
------- CA MARCHE	-------	DEBUT-------------------------------------------------

longeur				=	75.
hauteur_decal		=	25.




pt_1	=	[-25,10,0]
pt_3	=	[100,10,0]




pt_2	=	( pt_1 + pt_3) / 2 + [0,hauteur_decal,0 ]

--- le centre ----------------
Xc	=	 ( pt_1.x + pt_3.x) / 2 
Yc	=
	-(	( pt_2.x - pt_1.x ) / ( pt_2.y - pt_1.y ) )	* Xc		+	
	(	( pt_2.x^2 - pt_1.x^2  + pt_2.y^2  -  pt_1.y^2 )	/	(2*( pt_2.y - pt_1.y ) ) )
		 
		 
CENTRE =  [Xc, Yc,0 ]


po	pt_1
po	pt_2
po	pt_3

po centre
------- CA MARCHE	-------	FIN-------------------------------------






rayon 				= 100.
vec_rayon 	= [0,rayon,0]


angle_alpha	=	acos ((  rayon - hauteur_decal ) / rayon )

depose_point 	= vec_rayon * rotateZmatrix angle_alpha


intervale = 5.
for i = 0 to 2*angle_alpha by intervale	do (
	point pos:depose_point
	depose_point = depose_point * rotateZmatrix -intervale
)