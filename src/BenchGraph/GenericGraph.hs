module BenchGraph.GenericGraph
  (
  Vertex,
  Edge,
  Edges,
  Size,
  Name,
  GenericGraph,
  path,
  circuit,
  clique,
  mesh,
  complete,
  mkCompleteDir
  )

where

import BenchGraph.Named

type Vertex = Int
type Edge   = (Vertex,Vertex)
type Edges  = [Edge]
type Size   = Int

-- | Generic graph with a name. An empty list of edges means a single vertex 0
-- The function MUST be called with an @Int >= 1@
type GenericGraph = Named (Size -> (Edges,Int))

-- | A circuit is a path closed on himself
circuit :: GenericGraph
circuit = ("Circuit",mkCircuit)

mkCircuit :: Int -> (Edges,Int)
mkCircuit n = (fst (snd path n) ++ [(n'-1,0)], n')
  where
    n' = 10^n

-- | A clique is a graph such that every two distinct vertices are adjacent
clique :: GenericGraph
clique = ("Clique",mkClique)

mkClique :: Int -> (Edges,Int)
mkClique n = (concatMap (\cur -> (map (\x -> (cur, x)) [(cur+1)..(n'-1)])) [0..(n'-1)],n')
  where
    n' = 10^n

-- | A complete graph is a graph where every vertex has an edge to all the vertices of the graph
complete :: GenericGraph
complete = ("Complete",mkComplete)

mkComplete :: Int -> (Edges,Int)
mkComplete n = (mkCompleteDir n',n')
  where
    n' = 10^n

mkCompleteDir :: Int -> Edges
mkCompleteDir n' = concatMap (\cur -> (map (\x -> (cur, x)) [0..(n'-1)])) [0..(n'-1)]

-- | A mesh with @n@ vertices
mesh :: GenericGraph
mesh = ("Mesh",mkMesh)

mkMesh :: Int -> (Edges,Int)
mkMesh n = if n' == 1
              then ([],1)
           else (filter (\(x,y) -> x < n' && y < n') $ concatMap
              (\x -> let first = if (x+1) `mod` sq == 0 then [] else [(x,x+1)]
                         second = if x+sq >= sq^(2 :: Int) then [] else [(x,x+sq)]
                     in first ++ second
              )
              [0..(sq^(2::Int))], n')
  where
    sq = 1 + sq'
    sq' = round (sqrt $ fromRational $ toRational n' :: Double)
    n' = 10^n :: Int

-- | A path is a graph like [(0,1),(1,2),(2,3)..(n,n+1)]
path :: GenericGraph
path = ("Path",mkPath)

mkPath :: Int -> (Edges,Int)
mkPath n = (take (n'-1) $ iterate ((\(x,y) -> (x+1,y+1)) :: (Int,Int) -> (Int,Int)) (0,1),n')
  where
    n' = 10^n

