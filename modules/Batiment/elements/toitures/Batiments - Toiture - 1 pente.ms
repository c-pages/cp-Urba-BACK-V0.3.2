



--- parametres de base	-----------------------------
toiture_titre 	= "1 pente"	
toiture_type	=	#1pente
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	pente 		= 30,
	decalage_hauteur 	= 20
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture plate" width:180 height:70	(
	local m_rollPrt
	local m_compo
	
	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
	label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_longueur.value 	= 	m_compo.params.longueur
		edt_nom.text 			=	m_compo.nom
	)

	on spn_longueur changed val do (
		m_compo.params.longueur = val
		m_rollPrt.actualiser ()
	)
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local mgr_surface  		= 	_plug.core.get_mgr_surface ()
		local ptr_geo 				= 	_plug.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local toiture_pente 		= _composant.params.pente
		local toiture_hauteur		= _composant.params.decalage_hauteur
	
		local	 mtrx_axeP	=	mgr_surface.get_axePrincipal ()
		local	 BB_axeP		=	mgr_surface.get_axeP_BB ()
		translate mtrx_axeP	BB_axeP[1]
		
		local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		local hauteur 		= largeur * tan 		toiture_pente
		local z 					= pts_accroches[1].z
		
		local nvlsFaces 				= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----
		
		local pt_0 = (  [0,0,0]  *  mtrx_axeP )
		local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
		local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
		
		local vec1 = pt_1 - pt_0
		local vec2 = pt_2 - pt_0
		
		local pt_Origine = pt_0
		pt_Origine.z =  z + toiture_hauteur
		
		local plan_pente = ptr_geo.get_plan_2vecs_1Point		vec1		vec2		pt_Origine
		
		local pointsPente = #()
		local pointsMurs   =#()
		for i = 1 to  pts_accroches.count do (
			
			local j = i+1
			if j >  pts_accroches.count  do j = 1
			
			--- point Mur ----
			local pt 			= 	pts_accroches[i]	
			pt.z = z
			append pointsMurs  pt		
			
			local pt_result = plan_pente.projeter_point_verticalement 	pt
			
			append pointsPente  pt_result
			
		)
		
		--- creation de la face du dessus ----
		local faceDessus =  ptr_geo.face 	pointsPente 	
		append nvlsFaces faceDessus
		ptr_geo.set_matID  faceDessus	#toiture
		
		---- creation des raccord mur ----------
		local facesMurs = #()
		for i = 1 to pointsMurs.count  do (
			
			local j = i+1
			if j >  pointsMurs.count  do j = 1
			
			local ptMur1 		= pointsMurs[i]
			local ptMur2 		= pointsMurs[j]
			local ptPente3 	= pointsPente[j]
			local ptPente4	= pointsPente[i]
			
			local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
			local faceMurs = ptr_geo.face 	pointsRaccord
			
			ptr_geo.set_matID  faceMurs	#mur
			
			append nvlsFaces faceMurs
		)
	
		
		
		-- souder les points --
		local vertsASouder =#()
		for IDFace in nvlsFaces do (
			local vertsFace = polyop.getFaceVerts ptr_plug.delegate	 IDFace
			for vert in vertsFace do 
				appendIfUnique  vertsASouder 	vert
		)
		ptr_geo.souder		(vertsASouder as bitArray)
		
		
		---- debord et epaisseur du toit -----
		ptr_geo.biseauter	faceDessus 	0.0 	30.
		ptr_geo.extruder	faceDessus 	20.

		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_modelBase 	tooltip:toiture_tooltip		titre:toiture_titre	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	