{-# LANGUAGE DeriveFunctor #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Monoid.Recommend
-- Copyright   :  (c) 2012 diagrams-core team (see LICENSE)
-- License     :  BSD-style (see LICENSE)
-- Maintainer  :  diagrams-discuss@googlegroups.com
--
-- A type for representing values with an additional bit saying
-- whether the value is \"just a recommendation\" (to be used only if
-- nothing better comes along) or a \"committment\" (to certainly be
-- used, overriding merely recommended values), along with
-- corresponding @Semigroup@ and @Monoid@ instances.
--
-----------------------------------------------------------------------------

module Data.Monoid.Recommend
       ( Recommend(..), getRecommend
       ) where

import Data.Semigroup
import Data.Foldable (Foldable(..))
import Data.Traversable

-- | A value of type @Recommend a@ consists of a value of type @a@
--   wrapped up in one of two constructors.  The @Recommend@
--   constructor indicates a \"non-committal recommendation\"---that
--   is, the given value should be used if no other/better values are
--   available.  The @Commit@ constructor indicates a
--   \"commitment\"---a value which should definitely be used,
--   overriding any @Recommend@ed values.
data Recommend a = Recommend a
                 | Commit a
  deriving (Show, Eq, Functor)

-- | Extract the value of type @a@ wrapped in @Recommend a@.
getRecommend :: Recommend a -> a
getRecommend (Recommend a) = a
getRecommend (Commit a)    = a

-- | 'Commit' overrides 'Recommend'. Two values wrapped in the same
--   constructor (both 'Recommend' or both 'Commit') are combined
--   according to the underlying @Semigroup@ instance.
instance Semigroup a => Semigroup (Recommend a) where
  Recommend a <> Recommend b = Recommend (a <> b)
  Recommend _ <> Commit b    = Commit b
  Commit a    <> Recommend _ = Commit a
  Commit a    <> Commit b    = Commit (a <> b)

instance (Semigroup a, Monoid a) => Monoid (Recommend a) where
  mappend = (<>)
  mempty  = Recommend mempty

instance Foldable Recommend where
  foldMap = foldMapDefault

instance Traversable Recommend where
  traverse f (Commit    a) = fmap Commit    (f a)
  traverse f (Recommend a) = fmap Recommend (f a)
