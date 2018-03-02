struct str_mgr_material (
	
		
	----- material ---------------------
	private
		fn creer_material =(
			local matID 				= ( include "$userScripts\cp-Urba\Modules\Batiment\divers\Batiment - material IDs.ms" )
			local matIDs_noms	= getPropNames  	matID
			local ids 					= for   matID_nom in matIDs_noms collect ( 	getproperty matID	matID_nom )
			local materials 			= #()
			for   i = 1 to matIDs_noms.count	 do(
				local matID_nom	=	matIDs_noms[i]
				local val_color 		= 30*i + 30
				local variante 		= 40
				append materials    ( CoronaMtl name:matID_nom  colorDiffuse:[ val_color + random -variante variante  ,  val_color + random -variante variante , val_color   + random -variante variante  ] )				
			)
			
			local nvMat 					= multimaterial  	numsubs:0 --matIDs_noms.count
			nvMat.names 				= matIDs_noms
			nvMat.materialIDList		= ids
			nvMat.materialList			= materials
			
			nvMat
		),
	public 
		fn appliquer_material 	_this		=(
			local nvMat = creer_material ()
			_this.material = nvMat
			nvMat
		)
		
)