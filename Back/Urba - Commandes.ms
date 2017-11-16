
/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	LA BIBLIO
	GOF commande
	
##########################################################################################################################
	
	Gerer les undo redo de la biblio
	
	---- MODELE pour creer une commande ---------------------------------------
			struct 	cmd_MODELE  (		
				---- membres --------------------------------
				public
					m_edit,
				private
					m_data,
				
				---- fonctions  --------------------------------
				public
					fn executer 	=(			
					),
					fn refaire 	=(			
					),
					fn defaire =(			
					)
			)
	-------------------------------------------------------------------------
	
	
##########################################################################################################################*/



----------------------------------------------------------------------------------------
---- les commandes ------------------------------------------------------------------
----------------------------------------------------------------------------------------
struct 	cmd_commande_1  (	
	---- membres --------------------------------
	public
		m_membre,
		
	
	---- fonctions  --------------------------------
	public
		fn logger _typeCmd = (
			local logOut = "" 
			case _typeCmd of (
				#executer:	()
				#annuler:	logOut = "Annuler: "
				#refaire:		logOut = "Refaire: "
			)
			
			logOut += "Suppression de " + m_noeudsCibles.count as string + " asset(s)." 
			
			format  "%/n" logOut
		),
		
		fn executer  p1:	 p2: =	(
			---- données de la commande pour undo et redo ----
			format "parametre : %\n" (p1 as string)
			
			----action ----	
			format "executer commande 1\n"
			
		),
		fn refaire 			=	( 
			----action ----	
			format "refaire commande 1\n"
			
		),
		fn defaire 			=	(
			----action ----	
			format "défaire commande 1\n"
		)
)








---------------------------------------------------------------------------------------
---- le manager de commandes -------------------------------------------------------
---------------------------------------------------------------------------------------
struct str_commandeCtrl (
	------------ Les membres	----------------------------------------------------------------------------------		
	m_commande,						---- la commande à gerer 		----
	m_structActions,					---- la structure principale 		----
	m_chrono 	= str_chrono (),	---- pour chronometrer les operations ----
	
	------------ Les fonctions	----------------------------------------------------------------------------------		
	fn demarrerCommande =(
-- 		m_chrono.demarrer()
		setWaitCursor ()		
	),
	fn terminerCommande =(		
		setArrowCursor ()
	),
	
	fn setCommande 		_cmd	= ( m_commande = _cmd ),
	
	------------ Les actions	----------------------------------------------------------------------------------	
	fn executer 	p1:	p2:	= (
		
		demarrerCommande ()
		
		-- l'execution ---
		m_commande.executer p1:p1  p2:p2		
		m_commande.logger #executer
		
		terminerCommande ()
		
	),
	fn refaire 						= (
		
		demarrerCommande ()
		
		-- l'execution ---
		m_commande.refaire ()		
		m_commande.logger	#refaire
		
		terminerCommande ()
		
	),
	fn defaire 						= (
		
		demarrerCommande ()
		
		-- l'execution ---
		m_commande.defaire ()		
		m_commande.logger	#annuler
		
		terminerCommande ()
		
	),
	
	------------ Les evenements	----------------------------------------------------------------------------------	
	on clone do m_commande = copy m_commande
)




---------------------------------------------------------------------------------------
---- le controleur Prinicpale -------------------------------------------------------------------
---------------------------------------------------------------------------------------
struct str_commandesMgr (	
	------------ Les membres	----------------------------------------------------------------------------------	
	---- Pointeurs ----
	public
		m_structActions,
		
	---- Historique des actions ----
	private
		m_pileDefaire = #(),
		m_pileRefaire = #(),
		
	---- les Commandes ----
	private
		cmdMgr_cmd1		= str_commandeCtrl 	m_structActions:m_structActions,
		
	------------ Les fonctions	----------------------------------------------------------------------------------	
	private
		fn executer  _cmd 	p1:	p2:	=(
			local commande = copy 	_cmd
			m_pileRefaire =#()			
			commande.executer 	p1:p1 	p2:p2
			append	m_pileDefaire	commande
		),
	public
		fn	defaire =(
			if m_pileDefaire.count >0 do (
				
				local dernierDefaire = m_pileDefaire[m_pileDefaire.count]
				append 	m_pileRefaire 	dernierDefaire
				dernierDefaire.defaire ()
				deleteItem m_pileDefaire m_pileDefaire.count
			)
		),
		fn refaire = (
			if m_pileRefaire.count >0 do (
				
				local dernierRefaire = m_pileRefaire[m_pileRefaire.count]
				append 	m_pileDefaire 	dernierRefaire
				dernierRefaire.refaire ()
				deleteItem m_pileRefaire 	m_pileRefaire.count
			)
		), 
		
	---- les commandes ----
	public
		fn	cmd1 		param1 	param2					=	executer 	cmdMgr_cmd1 		p1:_ndASupprimer,
			
		---- tests des undos ----
		fn aDesUndo = m_pileDefaire.count >0,
		fn aDesRedo = m_pileRefaire.count >0,
			
	------------ Les evenements	----------------------------------------------------------------------------------	
		on create do (
			---- initialisation des commandes ----
			cmdMgr_cmd1.setCommande		( cmd_commande_1 			m_structActions:m_structActions )
		)
		
)

































