rollout rollout_recherche_list_view "list view" width:214 height:307
(
	
	
	
	
	dotNetControl tv_sequence	 "TreeView" pos:[11,7] width:190 height:290 align:#left
	
	
	
	fn creerItem 		_nvl_item 	_item_parent = (
		
		nouveauNoeudTV 		= _noeudParentTV.Nodes.add 		( _noeudA.nom + " (" + _noeudA.getNbrEnfants() as string + ")" )
		nouveauNoeudTV.name = _noeudA.nomUnique
		
	)
	
	fn vider_tv = (
		tv_sequence.Nodes.Clear()
	)
	fn initialiser = (
		
		---- TRee view ----
		tv_sequence.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
		tv_sequence.LabelEdit 				= true 
		tv_sequence.allowdrop 				= true
		tv_sequence.HideSelection 		= false
		tv_sequence.BackColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		tv_sequence.ForeColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
		tv_sequence.DrawMode 			= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
		
		
		theRoot = tv_sequence.Nodes.add 	"Sequence"
		
		
-- 		_noeudParentTV.Nodes.add 		( _noeudA.nom + " (" + _noeudA.getNbrEnfants() as string + ")" )
-- 		nouveauNoeudTV.name = _noeudA.nomUnique
	)
	
	
	
	
	
	on rollout_recherche_list_view		open do initialiser  ()
	
	
	
	
)







createDialog rollout_recherche_list_view

