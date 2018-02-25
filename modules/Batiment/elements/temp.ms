

porpsnames = getpropnames $
for propnom in porpsnames do (
	prop = getproperty $ propnom
	format "% :%\n" propnom  prop
)

mgr_fac = $.core.get_mgr_facades ()

mgr_fac.get_noms ()