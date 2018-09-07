/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - les parametres du plug
	
########################################################################################################################*/




parameters params_contours 						rollout:roll_contours		(
	
	p_contours						type:#nodeTab 			tabSize:0  		tabSizeVariable:true		----	Les shapes des batiments composant le quartier.
-- 	p_contours_utilises			type:#boolTab 			tabSize:0  		tabSizeVariable:true		----	Les shapes des batiments composant le quartier.
	p_batiments					type:#nodeTab 			tabSize:0  		tabSizeVariable:true		----	Les batiments composant le quartier.

	p_contours_surbrillance		type:#boolean				default:false	 	ui:chkbtn_surbillance	 	animatable:false		invisibleInTV:true		
	
)


parameters params_typologies						rollout:roll_typologies		(
	
	p_typologies					type:#stringTab 			tabSize:0  			tabSizeVariable:true				----	Les parametres (sous formes de DATAS (cf. manager Data to string) ) des differentes typologies du quartier.
	p_typologies_surbrillance	type:#boolean				default:false	 	ui:chkbtn_surbillance_typo	 	animatable:false		invisibleInTV:true		
	
)


parameters params_affichage						rollout:roll_affichage		(
	
	p_majAuto				type:#boolean			default:true	 	ui:ckb_majAuto	 	animatable:false		invisibleInTV:true		
	affiche_asProxy		type:#boolean			default:true	 	ui:ckb_proxies	 	animatable:false		invisibleInTV:true		
	
)
