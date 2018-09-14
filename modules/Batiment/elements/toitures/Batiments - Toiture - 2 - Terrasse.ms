


	
( ----	FileIn ----
	
	



--- parametres de base	-----------------------------
toiture_nom 		= "Terrasse"	
toiture_type		=	#terrasse
toiture_toolTip 	=	"..."

--- les parametres du composant	---------
struct toiture_params	(
	acrotere_ht = 50.,
	elements =#(),
	
	fn VP_afficher 	nd	surface_pts	z	=(
		
		z+= acrotere_ht
		
		local pts_etage =#()
		local ptID = 0 
		while ptID <  surface_pts.count do (
			ptID += 1
			local pt 						= surface_pts[ptID] *  nd.transform 
			pt.z = z
			append pts_etage pt
		)
		gw.setColor	#line		yellow
		gw.polyline pts_etage	true
		
		
		
		local ptID = 0 
		while ptID <  surface_pts.count do (
			ptID_precedant = ptID
			if ptID_precedant == 0  do ptID_precedant = surface_pts.count
			ptID += 1
			ptID_suivant = ptID + 1
			if ptID_suivant > surface_pts.count do ptID_suivant = 1
			
			
			
			local pt_precedant		= surface_pts[ptID_precedant] *  nd.transform 
			local pt 						= surface_pts[ptID] *  nd.transform 
			local pt_suivant			= surface_pts[ptID_suivant] *  nd.transform 

			pt.z = pt_precedant.z = pt_suivant.z = z
			
			local pt_encart = (nd.core.get_geo() ).encart 		pt				(pt_suivant - pt )	( pt_precedant - pt )  30	
			append pts_etage pt_encart
		)
		
		
		gw.setColor	#line		yellow
		gw.polyline pts_etage	true 
	)
	
)
--- les rollout du composant	---------
rollout toiture_dialog "Paramètres" width:230 height:374
(
	local m_plug
	local m_compo
	local m_rolloutP
	
	label 'lbl_htAcrotere' "Ht. acrotère:" pos:[5,-1] width:61 height:13 align:#left
	spinner 'spn_htAcrotere' "" pos:[148,-1] width:70 height:16 range:[0,100000,0] type:#float scale:1 align:#left
	
	
	listbox 'lbx_elements' "" pos:[9,50] width:201 height:4 align:#left
	button 'btn_elements_nouveau' "Nouv." pos:[9,34] width:35 height:16 align:#left
	button 'btn_elements_supprimer' "Supp." pos:[176,34] width:35 height:16 align:#left
	GroupBox 'grp_elements' "Elements" pos:[2,16] width:219 height:97 align:#left
	
	
	fn actualiser 	=(
		
		lbx_elements.items 						= for elem in m_compo.params.elements collect elem.nom		
		spn_htAcrotere.value 					= 	m_compo.params.acrotere_ht
		btn_elements_supprimer.enabled 	= lbx_elements.selection != 0
		
	)

	
	on spn_htAcrotere changed val do	(
			m_compo.params.acrotere_ht		= val
			m_rolloutP.changer_un_truc ()
		)
	on lbx_elements selected _index do
		actualiser ()
	on btn_elements_nouveau pressed do
			m_plug.core.get_menu_contructeur  #toitElements
	on btn_elements_supprimer pressed do
	(
		deleteItem 		m_compo.params.elements		lbx_elements.selection
		actualiser ()
		m_rolloutP.changer_un_truc ()
	)
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 this:		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	_plug.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local ep_murExt			= ptr_plug.const_murExt_epaisseur
		local ht_acrotere 		= ptr_composant.params.acrotere_ht
		local ep_couvertine		= ptr_plug.const_couvertine_epaisseur
		local ep_dalle				= ptr_plug.const_dalle_epaisseur
		
	
	
	
		if not  _plug.affiche_asProxy	then (
		-------------  CONSTRUCTION  NORMAL		-----------------------------------------------------------------------------------------------------------------
			
			--- la dalle	-------
			ptr_geo.facesContour	pts_accroches	 pts_accroches[1].z 		ep_dalle  matid:#mur
			for pt in pts_accroches do pt.z += ep_dalle
			
			--- la face de base 	--------
			local faceBase 	= ptr_geo.face		pts_accroches						matID:1
			ptr_geo.set_matID 	faceBase	#mur 
			
			--- l'acrotere --------
			ptr_geo.biseauter	faceBase 	0		 -ep_murExt
			ptr_geo.set_matID 	faceBase	#graviers 
			local faceAExtruder = #{ faceBase +1..(polyop.getNumFaces ptr_plug.delegate)} as array
			ptr_geo.extruder 	faceAExtruder 	ht_acrotere
			
			---- la couvertine  -----
			-- m_matID --
			ptr_geo.set_matID 	faceAExtruder	#metal 
			
			-- gemoetrie --
			ptr_geo.biseauter	faceAExtruder 	0		ep_couvertine
			ptr_geo.extruder 	faceAExtruder 			ep_couvertine
			
			---- les elements -----------
			if  this.params.elements.count > 0 do (
				local face_center = polyop.getFaceCenter  	ptr_plug.delegate  faceBase
				local faceNormal = polyop.getFaceNormal  	ptr_plug.delegate  faceBase
				
				local mgr_surface	= _plug.core.get_mgr_surface ()
				
				local mtrx_principale 	= mgr_surface.get_axePrincipal ()
				
				local transf_insertion		=	mtrx_principale * ( transMatrix face_center )  
				
				
				for elem in this.params.elements do
					elem.construire	 	ptr_plug			surface_points  	transformation:transf_insertion
			)
			
		)	---   FIN CONTRUCTION  NORMAL -----------------
		
		
		
		
		else (
		-------------  CONSTRUCTION  PROXY		-----------------------------------------------------------------------------------------------------------------
			
-- 			--- la dalle	-------
-- 			ptr_geo.facesContour	pts_accroches	 pts_accroches[1].z 		ep_dalle  matid:#mur
-- 			for pt in pts_accroches do pt.z += ep_dalle
			
			--- la face de base 	--------
			local faceBase 	= ptr_geo.face		pts_accroches						matID:1
			ptr_geo.set_matID 	faceBase	#mur 
			
			
-- 			--- l'acrotere --------
-- 			ptr_geo.biseauter	faceBase 	0		 -ep_murExt
-- 			ptr_geo.set_matID 	faceBase	#graviers 
			local faceAExtruder = #(faceBase)
			ptr_geo.extruder 	faceAExtruder 	ht_acrotere
-- 			
-- 			---- la couvertine  -----
-- 			-- m_matID --
-- 			ptr_geo.set_matID 	faceAExtruder	#metal 
			
			
		)
		
		
		/* 
		
		local faceToitsSurface = m_outils_poly.etendreFaces  	m_plug.delegate 	#(_face)
		
		
		
		-- m_matID --
		polyop.setFaceMatID m_plug.delegate  faceToitsSurface 	m_matID.toiture
		
		*/
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:toiture_tooltip		nom:toiture_nom	type:toiture_type	params:(toiture_params () )	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
	