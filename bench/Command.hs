module Command
  (
  Option (..),
  Output (..),
  Command (..),
  ListOption (..),
  CommandSpace (..),
  commandTime,
  runSpace,
  runDataSize
  )

where

import Options.Applicative
import Data.Semigroup ((<>))
import Data.Maybe (fromMaybe)

data Option = Part Int Int | Only String
  deriving (Show, Eq)

type Size = (Int,Int,Int)

data Output = Output {
  sumOut :: Bool, -- ^ Output summary ?
  staOut :: Bool -- ^ Output standard ?
  }
  deriving (Show, Eq)

type Only = String
type Lib = String

data ListOption = Benchs | Libs
  deriving (Show, Eq)

data Command = List ListOption | Run (Maybe Option) Output (Maybe [Lib]) Size
  deriving (Show, Eq)

data CommandSpace = ListS ListOption | RunS (Maybe Only) Output (Maybe [Lib])

partOpt :: Parser Option
partOpt = Part <$> rpart <*> rof
  where
    rpart = option auto (long "part")
    rof = option auto (long "of")

onlyOpt :: Parser String
onlyOpt = strOption (long "only" <> short 'o' <> metavar "NAME")

libOpt :: Parser String
libOpt = strOption (long "lib" <> short 'l' <> metavar "LIBNAME")

sizeOpt :: Parser Size
sizeOpt = option auto (long "graphs-size" <> value (3,3,2) <> showDefault <> help "(ten power to generate path, ten power to generate a circuit, ten power to generate a complete graph)" )

options :: Parser Option
options = partOpt <|> ( Only <$> onlyOpt)

sumFlag :: Parser Bool
sumFlag = flag True False $ long "noSummarize" <> short 's'

staFlag :: Parser Bool
staFlag = flag True False $ long "noStandard" <> short 'd'

output :: Parser Output
output = Output <$> sumFlag <*> staFlag

runCom :: Parser Command
runCom = Run <$> optional options <*> output <*> optional (some libOpt) <*> sizeOpt

listOpt :: Parser ListOption
listOpt = flag' Benchs (long "benchs") <|> flag' Libs (long "libs")

listCom :: Parser Command
listCom = List <$> listOpt

command' :: Parser Command
command' = subparser
  ( command "list" list
    <> command "run" run
  )
  where
    run = info (runCom <**> helper)
      ( fullDesc
      <> progDesc "Compare benchmarks of graphs libraries"
      <> header "Help" )
    list = info (listCom <**> helper)
      ( fullDesc
     <> progDesc "List benchmarks"
     <> header "Help" )

commandTime :: ParserInfo Command
commandTime = info (command' <**> helper)
      ( fullDesc
     <> progDesc "Benchmark time of functions on different graphs libraries"
     <> header "Help" )

space' :: Parser CommandSpace
space' = subparser
  ( command "list" list
    <> command "run" run
  )
  where
    list = info (ListS <$> listOpt <**> helper)
      ( fullDesc
      <> progDesc "Compare benchmarks of graphs libraries"
      <> header "Help" )
    run = info ( (RunS <$> optional onlyOpt <*> output <*> optional (some libOpt) ) <**> helper)
      ( fullDesc
     <> progDesc "list benchmarks"
     <> header "Help" )

runSpace :: ParserInfo CommandSpace
runSpace = info ( semiOptional <**> helper)
      ( fullDesc
     <> progDesc "Benchmark size of functions on different graphs libraries"
     <> header "Help")
  where
    semiOptional = pure (fromMaybe (RunS Nothing (Output True True) Nothing)) <*> optional space'

runDataSize :: ParserInfo Size
runDataSize = info (sizeOpt <**> helper)
     ( fullDesc
     <> progDesc "Benchmark datasize on different graphs representations"
     <> header "Help")

