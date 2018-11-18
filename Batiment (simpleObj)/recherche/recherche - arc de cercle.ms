ctre = [0,0,0]
r = 100
intervale = 10
/* for	x=  (ctre.x - R*(cos 45) ) to  (ctre.x + R*(cos 45) )  by intervale do (
	y  =	sqrt (R^2 - (x-ctre.x)^2)	+ctre.y
				point	pos:[x, y,0] 	size:2
)
for	y=  0 to  (ctre.y + R*(cos 45) ) by intervale  do (
	x  =	sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
				point	pos:[x, y,0] 	 	size:2
	x  =	- sqrt (R^2 - (y-ctre.y)^2)	+ctre.x
				point	pos:[x, y,0] 	 	size:2
) */



longeur				=	75.
hauteur_decal		=	50.

pt_1	=	[-25,10,0]
pt_3	=	[100,10,0]
pt_2	=	( pt_1 + pt_3) / 2 + [0,hauteur_decal,0 ]

-- pt_3	=	( pt_1 + pt_2) / 2 + [0,hauteur_decal,0 ]
-- pt_2	=	[100,10,0]



--- le centre ----------------
Xc	=	 ( pt_1.x + pt_3.x) / 2 
/* 

	(	( pt_3.x^2 - pt_2.x^2 + pt_3.y^2 - pt_2.y^2 )  /  ( 2 * ( pt_3.y - pt_2.y ) ) 	-	
		( pt_2.x^2 - pt_1.x^2 + pt_2.y^2 - pt_1.y^2 )  /  ( 2 * ( pt_2.y - pt_1.y ) ) 	)	/
	(	( ( pt_2.x - pt_1.x ) / ( pt_2.y - pt_1.y )	)		-	( ( pt_3.x - pt_2.x ) / ( pt_3.y - pt_2.y )	)	)
	 */
Yc	=
	-(	( pt_2.x - pt_1.x ) / ( pt_2.y - pt_1.y ) )	* Xc		+	
	(	( pt_2.x^2 - pt_1.x^2  + pt_2.y^2  -  pt_1.y^2 )	/	2*( pt_2.y - pt_1.y ) )
		 
		 
		 
		 
		 
rayon 				= 100.
vec_rayon 	= [0,rayon,0]


angle_alpha	=	acos ((  rayon - hauteur_decal ) / rayon )

depose_point 	= vec_rayon * rotateZmatrix angle_alpha


intervale = 5.
for i = 0 to 2*angle_alpha by intervale	do (
	point pos:depose_point
	depose_point = depose_point * rotateZmatrix -intervale
)