
------ OUTPUTS	------------------------------------------------------------------------------------------------------------------------------------


----- debug ------------------------------
global debug, debuger, ecrire, debug_spline, debug_point
global DEBUG_MODE = true


fn creer_debug_pts	_liste_pos =(
	
	
	fn creer_pt 	posit =(
		p =   point pos:posit		name:"pt_debug" centermarker:on axistripod:off cross:on Box:off  constantscreensize:off drawontop:off 
		selectmore p
	)
	case classof _liste_pos of (
		Point3:creer_pt  _liste_pos
		array: (
			if _liste_pos.count > 0 do (	
				---- recursif pour tableau dans tableau ---------
				if  classof _liste_pos[1] == array then (
					for pos in _liste_pos do creer_debug_pts 	pos
				) else (
					for pos in _liste_pos do	
						creer_pt 	pos
				)
			)
		)
	) --- fin case
	
)


fn creer_debug_splines	_liste_pos 	nom:	=(
	
	local result =#()
	fn creer_spline 	_pos 		nom:nom		=(
		sp = splineShape name:(uniquename nom )
		pts = _pos
		addnewSpline sp
		for pt in pts do		addknot sp 1 #corner #curve  pt
		close sp 1
		updateShape sp
		selectmore sp
		sp
	)
	
	
	
	case classof _liste_pos of (
		Point3:creer_debug_pts  _liste_pos	nom:nom	
		array: (
			if _liste_pos.count > 0 do (
				---- recursif pour tableau dans tableau ---------
				if  classof _liste_pos[1] == array then 
							for pos in _liste_pos do creer_debug_splines 	pos 	nom:nom	
					else 
						append result ( creer_spline 	_liste_pos 	nom:nom	)
				
			)
		)
	) --- fin case
	result
)



fn debug_point 	_pos	=  if DEBUG_MODE do  (
	
	

-- 	try delete $pt_debug* catch ()
	clearselection ()
	
	creer_debug_pts		_pos

)
fn debug_spline 	_pos	nom:"li_debug"		=   if DEBUG_MODE do  (
	
	try delete $li_debug* catch ()
	clearselection ()
	
	creer_debug_splines	_pos 	nom:nom
	
)


fn po  _var	= (
	
			
	local dbg_mode_BAck = ::debug_mode
	::debug_mode = true
	
	debug_point	_var
	
	::debug_mode = dbg_mode_BAck
	
	
)
fn li 	_var	= (
	
	local dbg_mode_BAck = ::debug_mode
	::debug_mode = true
	
	debug_spline		_var

	::debug_mode = dbg_mode_BAck
	

	
)





fn remplirTexte  _txt  var:	 param:  prefix: = (
	
	local result =""
	global dbg_elemTmp
	if prefix != unsupplied and prefix != undefined do (
		result += "<" + prefix + ">	"
-- 		if prefix.count < 10 do result += "	"
		if prefix.count < 6 do result += "	"
		if prefix.count < 2 do result += "	"
	)
	if var != unsupplied then (
		
		result += _txt +  " : "	
		
		if classof 	var == Array then (
			
			if param != unsupplied then (
-- 				result += "(" + var.count as string + ")  "
				result += "#( " 
				for i = 1 to var.count do (
						if var[i]	 != undefined then (
						dbg_elemTmp	= var[i]					
						
						result +=  ( execute ("dbg_elemTmp." + param ) ) as string 
						
						if i != var.count	do result += ", "
					) else result += "undefined"
				)
				
				result += " )" 
			) else 	result += with printAllElements true ( var ) as string
		) else 
		if param != unsupplied  then (
			if var != undefined then (
				dbg_elemTmp	= var
				result += ( execute ("dbg_elemTmp." + param ) ) as string 
			) else 	result += "undefined"
		) else 	result += var as string
	) else 	result += _txt
	result
)

fn debuger	_txt  var:	 param:    prefix: = 	(
	if DEBUG_MODE   do (
		local txtFinal = "" --"<DEBUG>	"
		
		txtFinal += remplirTexte  _txt  var:var	 param:param 	prefix:prefix
		
		with printAllElements true ( format "%\n"	txtFinal )
	)
)		
----- output ------------------------------
fn ecrire 		_txt  var:	 param:   script:"Labib"	= 	(
	if not DEBUG_MODE then  (
		
		local txtFinal = "<" + script + ">	"		
		
		txtFinal += remplirTexte  _txt  var:var	 param:param
		with printAllElements true ( format "%\n"	txtFinal )
	) else debuger 	_txt  	var:var	 param:param	
)

------ OUTPUT	------------------------------------------------------------------------------------------------------------------------------------
