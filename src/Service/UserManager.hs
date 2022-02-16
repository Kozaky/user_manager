module Service.UserManager (getUser, createUser, editUser) where

import Data.Functor ((<&>))
import qualified Data.Text as T
import Database (DbFailure, Documentable (fromDocument, toDocument), runQuery)
import Foundation (App)
import Query.User
  ( findUserById,
    insertUser,
    updateUser,
  )
import Types.User (CreateUserReq, EditUserReq, UserDTO, userDTOfromUser, userFromCreateUserReq)

createUser :: CreateUserReq -> App T.Text
createUser req =
  runQuery $
    insertUser (toDocument $ userFromCreateUserReq req) <&> (T.pack . show)

getUser :: T.Text -> App (Either T.Text UserDTO)
getUser userId = do
  runQuery $ do
    mDoc <- findUserById $ read . T.unpack $ userId

    case mDoc of
      Just doc -> return . Right . userDTOfromUser . fromDocument $ doc
      Nothing -> return $ Left "User not found"

editUser :: T.Text -> EditUserReq -> App (Either DbFailure ())
editUser userId req = do
  runQuery $ updateUser (read . T.unpack $ userId) req
