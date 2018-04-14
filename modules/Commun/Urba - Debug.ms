
------ OUTPUTS	------------------------------------------------------------------------------------------------------------------------------------


----- debug ------------------------------
global debug, debuger, ecrire, pos
global DEBUG_MODE = true


fn pos 	_pos	= (
	case classof _pos of (
		Point3: (
			try delete $p catch ()
			p =   point pos:_pos		name:"p" centermarker:off axistripod:off cross:on Box:on size:10 constantscreensize:off drawontop:off wirecolor:yellow
			select p
		)
		array: (
			try delete $sp catch ()
			sp = splineShape name:"sp"
			pts = _pos
			addnewSpline sp
			for pt in pts do		addknot sp 1 #corner #curve  pt
			close sp 1
			updateShape sp
			select sp
		)
		
		
	)

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
		
		result += "	- " + _txt +  " : "	
		
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
