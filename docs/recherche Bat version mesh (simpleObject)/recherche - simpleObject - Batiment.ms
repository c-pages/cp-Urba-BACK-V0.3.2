
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\mgr - presets.ms"

include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ensemble.ms"


plugin simpleObject 	urba_batiment_temp
name:"Bâtiment"
classID:#(0x3b4d5bbe, 0x5e541a1)
category:"CP | Urba | Bâtiment"
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_batiment_temp"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	
	-----------------    VARIABLES ----------------------------------------------------------------------------------------------------------------------
-- 	local roll_ensembleMenuis
-- 	local m_sequence 	=	#()
	local mgr_presets 	=	str_presets_manager ()
	
	
	

	
	
	
	
	
	
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters param_transformation		(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters param_general rollout:roll_general	(
		
	)----- fin parameters main	---------------------------
	
	
	
	
	
	------------ ROLLOUT	----------------------------------------------------------------------------------------------------------------------
	rollout roll_general	"General"	(
		
		
	)----- fin roll_general	---------------------------
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create	(
		on mousePoint click do ( 
			nodeTM.translation = gridPoint
			#stop
		)
	) --- fin tool create	---------------------------
	
	
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do
	(
		---- on vide le mesh -----------
-- 		delete mesh
		
	) --- fin buildMesh	---------------------------
	
) -----------	fin plugin --------------------















