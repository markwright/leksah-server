{-# OPTIONS_GHC
    -XScopedTypeVariables
    -XStandaloneDeriving
    -XDeriveDataTypeable
    -fno-warn-orphans #-}

-----------------------------------------------------------------------------
--
-- Module      :  IDE.Core.Serializable
-- Copyright   :  2007-2011 Juergen Nicklisch-Franken, Hamish Mackenzie
-- License     :  GPL
--
-- Maintainer  :  Jutaro <jutaro@leksah.org>
-- Stability   :  provisional
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module IDE.Core.Serializable (


) where

import Distribution.Text (simpleParse,display)
import Control.Monad (liftM)
import Data.Maybe (fromJust)
import Data.Binary.Shared (BinaryShared(..))
import Distribution.Package (PackageName(..),PackageIdentifier(..))
import Data.Version (Version(..))
import Distribution.ModuleName (ModuleName)

import IDE.Core.CTypes
import Data.Typeable (Typeable)

#if !MIN_VERSION_ghc(7,7,0)
deriving instance Typeable PackageIdentifier
deriving instance Typeable ModuleName
deriving instance Typeable PackageName
#endif
-----------------------------------------------------------

instance BinaryShared PackModule where
    put =   putShared (\ (PM pack' modu') -> do
                (put pack')
                (put modu'))
    get =   getShared (do
                pack'                <- get
                modu'                <- get
                return (PM pack' modu'))


instance BinaryShared PackageIdentifier where
    put =   putShared  (\ (PackageIdentifier name' version') -> do
                put name'
                put version')
    get =   getShared (do
                name'                <- get
                version'             <- get
                return (PackageIdentifier name' version'))

instance BinaryShared Version where
    put =   putShared (\ (Version branch' tags') -> do
                put branch'
                put tags')
    get =   getShared (do
                branch'              <- get
                tags'                <- get
                return (Version branch' tags'))

instance BinaryShared PackageDescr where
    put =   putShared (\ (PackageDescr packagePD' exposedModulesPD' buildDependsPD'
                                        mbSourcePathPD') -> do
                put packagePD'
                put exposedModulesPD'
                put buildDependsPD'
                put mbSourcePathPD')
    get =   getShared (do
                packagePD'           <- get
                exposedModulesPD'    <- get
                buildDependsPD'      <- get
                mbSourcePathPD'      <- get
                return (PackageDescr packagePD' exposedModulesPD' buildDependsPD'
                                        mbSourcePathPD'))

instance BinaryShared ModuleDescr where
    put = putShared (\ (ModuleDescr moduleIdMD' mbSourcePathMD' usagesMD'
                idDescriptionsMD') -> do
            put moduleIdMD'
            put mbSourcePathMD'
            put usagesMD'
            put idDescriptionsMD')
    get = getShared (do
            moduleIdMD'          <- get
            mbSourcePathMD'      <- get
            usagesMD'            <- get
            idDescriptionsMD'    <- get
            return (ModuleDescr moduleIdMD' mbSourcePathMD'
                                usagesMD' idDescriptionsMD'))

instance BinaryShared Descr where
    put (Real (RealDescr descrName2 typeInfo2 descrModu2 mbLocation2 mbComment2 details2 isExp))
        = do    put (1:: Int)
                put descrName2
                put typeInfo2
                put descrModu2
                put mbLocation2
                put mbComment2
                put details2
                put isExp
    put (Reexported (ReexportedDescr reexpModu' impDescr'))
        = do    put (2:: Int)
                put reexpModu'
                put impDescr'
    get = do    (typeHint :: Int) <- get
                case typeHint of
                    1 -> do
                        descrName2          <- get
                        typeInfo2           <- get
                        descrModu2          <- get
                        mbLocation2         <- get
                        mbComment2          <- get
                        details2            <- get
                        isExp2              <- get
                        return (Real (RealDescr descrName2 typeInfo2 descrModu2 mbLocation2
                            mbComment2 details2 isExp2))
                    2 -> do
                        reexpModu'          <- get
                        impDescr'           <- get
                        return (Reexported (ReexportedDescr reexpModu' impDescr'))
                    _ -> error "Impossible in Binary Descr get"

instance BinaryShared TypeDescr where
    put VariableDescr
        = do    put (1:: Int)
    put (FieldDescr typeDescrF')
        = do    put (2:: Int)
                put typeDescrF'
    put (ConstructorDescr typeDescrC')
        = do    put (3:: Int)
                put typeDescrC'
    put (DataDescr constructors' fields')
        = do    put (4:: Int)
                put constructors'
                put fields'
    put TypeDescr
        = do    put (5:: Int)
    put (NewtypeDescr constructor' mbField')
        = do    put (6:: Int)
                put constructor'
                put mbField'
    put (ClassDescr super' methods')
        = do    put (7:: Int)
                put super'
                put methods'
    put (MethodDescr classDescrM')
        = do    put (8:: Int)
                put classDescrM'
    put (InstanceDescr binds')
        = do    put (9:: Int)
                put binds'
    put KeywordDescr
        = do    put (10:: Int)
    put ExtensionDescr
        = do    put (11:: Int)
    put ModNameDescr
        = do    put (12:: Int)
    put QualModNameDescr
        = do    put (13:: Int)
    put ErrorDescr
        = do    put (14:: Int)

    get = do    (typeHint :: Int)                <- get
                case typeHint of
                    1 -> return VariableDescr
                    2 -> do
                            typeDescrF'         <- get
                            return (FieldDescr typeDescrF')
                    3 -> do
                            typeDescrC'         <- get
                            return (ConstructorDescr typeDescrC')
                    4 -> do
                            constructors'       <- get
                            fields'             <- get
                            return (DataDescr constructors' fields')
                    5 -> return TypeDescr
                    6 -> do
                            constructor'        <- get
                            mbField'            <- get
                            return (NewtypeDescr constructor' mbField')
                    7 -> do
                            super'              <- get
                            methods'            <- get
                            return (ClassDescr super' methods')
                    8 -> do
                            classDescrM'        <- get
                            return (MethodDescr classDescrM')
                    9 -> do
                            binds'              <- get
                            return (InstanceDescr binds')
                    10 -> return KeywordDescr
                    11 -> return ExtensionDescr
                    12 -> return ModNameDescr
                    13 -> return QualModNameDescr
                    14 -> return ErrorDescr
                    _ -> error "Impossible in Binary SpDescr get"

instance BinaryShared SimpleDescr where
    put (SimpleDescr sdName' sdType' sdLocation' sdComment' sdExported')
        = do    put sdName'
                put sdType'
                put sdLocation'
                put sdComment'
                put sdExported'
    get = do    sdName'           <-  get
                sdType'           <-  get
                sdLocation'       <-  get
                sdComment'        <-  get
                sdExported'       <-  get
                return (SimpleDescr sdName' sdType' sdLocation' sdComment' sdExported')

instance BinaryShared Location where
    put (Location locationSLine' locationSCol' locationELine' locationECol')
        = do    put locationSLine'
                put locationSCol'
                put locationELine'
                put locationECol'
    get = do    locationSLine'       <-  get
                locationSCol'        <-  get
                locationELine'       <-  get
                locationECol'        <-  get
                return (Location locationSLine' locationSCol' locationELine' locationECol')


instance BinaryShared ModuleName where
    put    =  put . display
    get    =  liftM (fromJust . simpleParse) get

instance BinaryShared PackageName where
    put (PackageName pn) =  put pn
    get  =  liftM PackageName get



