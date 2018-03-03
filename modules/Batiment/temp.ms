



fn dupliquer		 _struct_original	=(
	
	local nv_struct = copy _struct_original
	for propnom in getpropNames _struct_original do (
		
		local val_orig = getProperty  _struct_original	propnom
		local val_dup
		
		--- si on a un struct ------
		if superclassOf val_orig == StructDef then 
			val_dup = dupliquer  val_orig
		
		-- sinon on regarde si on a un tableau
		else if  classof val_orig ==  array then (		
			if val_orig.count> 0 then (
				if superclassOf val_orig[1] == StructDef then
					val_dup = for valTab_orig in val_orig collect dupliquer  valTab_orig
				else
					val_dup = for valTab_orig in val_orig collect copy  valTab_orig
			) else val_dup = #()
		
		---- sinon on a une valeur de base -------
		) else val_dup = copy val_orig
			
		
		setproperty	nv_struct	propnom 	val_dup
	)
	nv_struct
) -- fin dupliquer








struct str_C (
	valC1 	= "TITI",
	valC2	=	#()
)


struct str_B (
	valB1 	= "popo",
	valB2	=	#( str_C 	valC1:"PREMIER C", str_C valC1:"SECOND C")
)

struct str_A (
	valA1 	= 1,
	valA2	=	str_B ()
)


















clearlistener ()

data_A 			= str_A ()
data_A_DUP 	=  dupliquer  data_A


data_A_DUP.valA2.valB2[1].valC1 = "CHANGEMENT"
-- data_A_DUP.valA2.valB2[1].valC2[1] = 117
format "DUPLICATION : \n1)	%\n2)	%\n"	data_A_DUP.valA2.valB2 	data_A.valA2.valB2


























