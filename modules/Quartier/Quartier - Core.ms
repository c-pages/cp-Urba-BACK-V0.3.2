/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - le coeur du plug.
	
########################################################################################################################*/


include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Geometrie.ms"


--- la sturucture centrale du plug in ------------------------------------------
struct str_quartier_core (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | Quartier CORE",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	-------- MEMBRES	--------------------------------------------------------------------------------------------------------
	
	private
	---- pointeur  vers le plugin --------------------
		m_plug,
	
	---- geometrie --------------
		m_geo		= 	str_geometrie 	(),
	
	---- tracé Logo  -------------------
		m_logo = #([-1900,-100,0], [1900,-100,0], [1900,3.05176e-05,0], [1500,3.05176e-05,0], [1500,100,0], [1400,200,0], [1300,100,0], [1300,3.05176e-05,0], [1100,3.05176e-05,0], \
						[1100,600,0], [800,600,0], [800,300,0], [600,300,0], [600,500,0], [400,700,0], [400,100,0], [300,200,0], [200,100,0], [200,300,0], [-100,300,0], [-100,200,0], [-300,400,0], \
						[-300,700,0], [-500,700,0], [-500,400,0], [-600,500,0], [-700,400,0], [-700,100,0], [-800,200,0], [-900,100,0], [-1000,3.05176e-05,0], [-1200,3.05176e-05,0], [-1200,100,0], \
						[-1300,200,0], [-1400,100,0], [-1400,3.05176e-05,0], [-1900,3.05176e-05,0]),


	----- liste des struct de typologies -----------------------
		m_typologies						=	#(),	----	Les models des batiments à utiliser pour construir le quartier.
	
	
	/* 
	---- Parametres du plugin ---------------------------------
		m_contours							=	#(),	----	Les shapes des batiments composant le quartier.
		m_batiments						=	#(),	----	Les models des batiments à utiliser pour construir le quartier.
		
		m_conditions_surfMin_use		=	#(),	----	Utilisation d'une condition de surface minimum pour choisir le contour du batiment.	(tableau de booleans)
		m_conditions_surfMin			=	#(),	----	Surface minimum du contour pour être choisi.		(tableau de floats)
		m_conditions_surfMax_use		=	#(),	----	Utilisation d'une condition de surface maximum pour choisir le contour du batiment.	(tableau de booleans)
		m_conditions_surfMax			=	#(),	----	Surface maximum du contour pour être choisi.		(tableau de floats)
	
		m_conditions_largMin_use		=	#(),	----	Utilisation d'une condition de largeur minimum pour choisir le contour du batiment.		(tableau de booleans)
		m_conditions_largMin			=	#(),	----	largeur minimum du contour pour être choisi.		(tableau de floats)
		m_conditions_largMax_use		=	#(),	----	Utilisation d'une condition de largeur maximum pour choisir le contour du batiment.	(tableau de booleans)
		m_conditions_largMax			=	#(),	----	largeur maximum du contour pour être choisi.		(tableau de floats)
	
		m_conditions_longMin_use		=	#(),	----	Utilisation d'une condition de longueur minimum pour choisir le contour du batiment.	(tableau de booleans)
		m_conditions_longMin			=	#(),	----	longueur minimum du contour pour être choisi.		(tableau de floats)
		m_conditions_longMax_use	=	#(),	----	Utilisation d'une condition de longueur maximum pour choisir le contour du batiment.	(tableau de booleans)
		m_conditions_longMax			=	#(),	----	longueur maximum du contour pour être choisi.		(tableau de floats)
		
		m_variations_nbrEtages			=	#(),	----	Nombre d'étages à ajouter ou a soustraire aux nombres d'étages du model				(tableau de integers)
		m_variations_nbrEtagesMin	=	#(),	----	Nombre d'étages minimum.		(tableau de integers)
		m_variations_nbrEtagesMax	=	#(),	----	Nombre d'étages maximum.		(tableau de integers)
	 */
	
	
	
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------

		
	
	
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public
		------ global --------------
		fn initialiser 	_plug	= (
			debug "initialiser"
			m_plug = _plug
			m_geo.initialiser	_plug			
		),
		fn actualiser	=(
			debug "actualiser"
			m_geo.face		m_logo
		),
		
		
		---- Models de quartier ----------------
		fn charger 			_fichierModel	= (),
		fn enregistrer		_fichierModel	= (),
		
		
		
		
		
		------ contours --------------
		fn	ajouter_contour		_shp		=		appendIfUnique	m_plug.p_contours		_shp,
		fn	ajouter_contours		_shps	=		for shp in _shps do	ajouter_contour		shp,
		fn retirer_contour		_id_shp	=	()
		
)



























