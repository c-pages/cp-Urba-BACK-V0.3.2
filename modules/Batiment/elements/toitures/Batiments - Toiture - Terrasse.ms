



--- parametres de base	-----------------------------
toiture_titre 	= "Terrasse"	
toiture_type	=	#terrasse
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	acrotere_ht = 50.
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture plate" width:180 height:70	(
	local m_plug
	local m_toiture
	local mgr_toiture
	
	label 'lbl_htAcrotere' "Ht. acrot�re:" pos:[9,10] width:61 height:13 align:#left
	spinner 'spn_htAcrotere' "" pos:[92,9] width:70 height:16 range:[0,100000,0] type:#float scale:1 align:#left
	fn actualiser =(
		spn_htAcrotere.value 	= 	m_toiture.params.acrotere_ht
	)

	fn initialiser _plug	_toiture	=(
		m_plug			= _plug
		m_toiture 		= _toiture
		mgr_toiture	= m_plug.core.get_mgr_toiture ()
		actualiser ()
	)

	on spn_htAcrotere changed val do (
		m_toiture.params.acrotere_ht		= val
		mgr_toiture.enregistrer ()
		m_plug.core.actualiser ()
	)
	
	
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	_composant
		local ptr_geo 				= 	_plug.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local ep_murExt		= ptr_plug.const_murExt_epaisseur
		local ht_acrotere 		= ptr_composant.params.acrotere_ht
		local ep_couvertine	= ptr_plug.const_couvertine_epaisseur
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		
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
		
		/* 
		
		local faceToitsSurface = m_outils_poly.etendreFaces  	m_plug.delegate 	#(_face)
		
		
		
		-- m_matID --
		polyop.setFaceMatID m_plug.delegate  faceToitsSurface 	m_matID.toiture
		
		*/
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_modelBase		tooltip:toiture_tooltip		titre:toiture_titre	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	