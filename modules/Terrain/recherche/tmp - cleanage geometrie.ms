grille_segts			=	 polyop.getEdgeSelection $
total_segts 		= #{1..polyop.getNumEdges $}
bordure_segts		=	polyop.getOpenEdges $ 
invis_segts 		= total_segts - grille_segts - bordure_segts
polyOp.setEdgeSelection $ invis_segts

ids_pts_aVirer = polyop.getVertsUsingEdge $ invis_segts
ids_pts_aVirer.count
-- for	i = 1 to 	ids_pts_aVirer.count do (
for	id_pt_aVirer in 	ids_pts_aVirer do (
-- 	local id_pt_aVirer = ids_pts_aVirer[
	local sgts_duPoint = polyop.getEdgesUsingVert    $ 	id_pt_aVirer
	for id_sgt_duPoint in sgts_duPoint do (
-- 		format "id_sgt_duPoint :%\n" id_sgt_duPoint
-- 		format "bordure_segts[ id_pt_aVirer ] :%\n" bordure_segts[ id_sgt_duPoint ]
		if bordure_segts[ id_sgt_duPoint ] do 
			ids_pts_aVirer[ id_pt_aVirer ] = false
	)
)
ids_pts_aVirer.count

	



polyOp.setVertSelection $ ids_pts_aVirer
$.remove selLevel:#edge
$.remove selLevel:#vertex




polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}