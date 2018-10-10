

include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"

plugin simpleObject		urba_menuis_poignee
name:"poignée porte"
classID:#(0x1de1da82, 0x16d00262)
category:"CP | Urba | menuiseries"
invisible:false
(
	
	local mgr_constr	=	str_contruction_base ()
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters params_general 		(
		inverser_sens_ouverture		type:#boolean 		default:false
		matId								type:#integer 			default:3
	)
	
		------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	nodeTM.translation = gridPoint
						#stop
					)
			)
	) --- fin tool create ---------
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	
	
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		---- accroche	----------
		mgr_constr.ajouter_boite 	mesh		long:			4		\
														prof:			.5		\
														ht:			18		\
														matId:		matId
		
		---- poignée	----------
		mgr_constr.ajouter_boite 	mesh		long:			1			\
														prof:			2.5		\
														ht:			1			\
														transf:		[1.5, 0.5, 11.5]	\
														matId:		matId
		
		local decalle_x = 1.5
		if	not inverser_sens_ouverture then	decalle_x = -7.5
			
			mgr_constr.ajouter_boite 	mesh		long:			10		\
															prof:			1		\
															ht:			1		\
															transf:		[ decalle_x , 3, 11.5]	\
															matId:		matId
	
	)  ----- fin on buld mesh -----------------
	
	
)