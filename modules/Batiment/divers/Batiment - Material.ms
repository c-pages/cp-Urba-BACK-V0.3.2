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
-- 				format  "matID_nom : %\n" matID_nom
				case matID_nom of (
					#menuiserie :(
						local val_color 		= color 120 120 120 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color  levelReflect:.9   reflectGlossiness:.8 )
					)
					#volet :(
						local val_color 		= color 120 120 120 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color  levelReflect:.5   reflectGlossiness:.8 )
					)
					#volet_LP :(
						local val_color 		= color 120 120 120 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color  levelReflect:.5   reflectGlossiness:.8 )
					
					
					)
					#vitrage :(
						local val_color 		= color 0 0 0 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color  levelReflect:1   levelRefract:.3  thin:true )
					)
					#mur: (
						
						local val_color 		= color 200 200 200 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color )				
						
					)
					#int_mur: (
						
						local val_color 		= color 250 250 250 
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:val_color )				
						
					)
					default: (
						
						local val_color 		= 30*i + 30
						local variante 		= 40
						append materials    ( CoronaMtl name:matID_nom  colorDiffuse:[ val_color + random -variante variante  ,  val_color + random -variante variante , val_color   + random -variante variante  ] )				
						
					)
				)
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