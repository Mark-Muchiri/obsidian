### `Bite-sized Project todo Tasks`

Here you'll only write down simple broken down tasks that can be done within a day or 1 , 2 hrs

#### _`Tasks`_
>Need to work on consuming the user authentication API. And check whether the email inserted is in `email` format
> - The user should be able to:
>	- [ ] Register
>	- [ ] Login
>	- [ ] Read their user information 
>	- [ ] Update their data
>	- [ ] Delete/freeze their account 

> #### _NB:_
> - _From the **"[1. Project check-list](:/2864c64fdfdb440faafb97e721b1d631)"** notes_
> 
> - `User Authentication > Tasks`
---
<br>

## Register , Login

### _`Tasks`_

#### User Regitration:

- [x] Make a Register page with the following data:
	- File input section
	- Username
   - First name
	- Last name
	- Email
	- Phone number
	- Town
	- Street
	- Estate
	- Country
	- Password
	- Confirm Password

> NB: remember to add the `username` and `profile_picture` to the data model. The `username` should be required.

- [x] Make a Login page with the following data:
	- Email
	- Password
	- [Link]() for forgot pasword (Password rcovery)

- [ ] Make a **_spinner_** for loading conditions.

- [ ] Consume API for **_registration_**.

   - Customize some bits of the code. Below are sections you should edit.

```js
   const [formData, setFormData] = useState({
      name: '',
      email: '',
      password: '',
      password2: '',
   })

   const { name, email, password, password2 } = formData


   const { user, isLoading, isError, isSuccess, message } = useSelector(
      (state) => state.auth
      )
```

   - The array at the bottom of this `useEffect`.

```js
   useEffect(() => {
      if (isError) {
         toast.error(message)
     }

      if (isSuccess || user) {
         navigate('/')
      }

      dispatch(reset())
   }, [user, isError, isSuccess, message, navigate, dispatch])
```

- [ ] Consume API for **_login_**.

   - Customize some bits of the code. Below are sections you should edit.

```js
   const [formData, setFormData] = useState({
      email: '',
      password: '',
   })

   const { email, password } = formData
```
---
<br>

#### After That reasses for next steps to be taken.

The next task to check is:

![Screenshot from 2023-01-13 06-54-24.png. This is a screenshot of react folders for a general idea of the folder/file arrangements](:/481204cf2fee4ebb9bfd212320d99f5a)

#### Remember to plan before excecution, to make excecution faster and esaier

