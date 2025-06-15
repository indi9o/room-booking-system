from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Div
from bootstrap_datepicker_plus.widgets import DateTimePickerInput
from .models import Room, Booking

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True)
    first_name = forms.CharField(max_length=30, required=True)
    last_name = forms.CharField(max_length=30, required=True)

    class Meta:
        model = User
        fields = ("username", "email", "first_name", "last_name", "password1", "password2")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.helper = FormHelper()
        self.helper.layout = Layout(
            Row(
                Column('first_name', css_class='form-group col-md-6 mb-0'),
                Column('last_name', css_class='form-group col-md-6 mb-0'),
                css_class='form-row'
            ),
            'username',
            'email',
            'password1',
            'password2',
            Submit('submit', 'Daftar', css_class='btn btn-primary')
        )

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        user.first_name = self.cleaned_data["first_name"]
        user.last_name = self.cleaned_data["last_name"]
        if commit:
            user.save()
        return user

class RoomForm(forms.ModelForm):
    class Meta:
        model = Room
        fields = ['name', 'description', 'capacity', 'location', 'facilities', 'image', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Masukkan nama ruangan'
            }),
            'description': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'Deskripsi ruangan (opsional)'
            }),
            'capacity': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'Kapasitas maksimal',
                'min': 1
            }),
            'location': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Lokasi ruangan'
            }),
            'facilities': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 3,
                'placeholder': 'Fasilitas yang tersedia (pisahkan dengan koma)'
            }),
            'image': forms.FileInput(attrs={
                'class': 'form-control',
                'accept': 'image/*'
            }),
            'is_active': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            }),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Set field labels
        self.fields['name'].label = 'Nama Ruangan'
        self.fields['description'].label = 'Deskripsi'
        self.fields['capacity'].label = 'Kapasitas'
        self.fields['location'].label = 'Lokasi'
        self.fields['facilities'].label = 'Fasilitas'
        self.fields['image'].label = 'Foto Ruangan'
        self.fields['is_active'].label = 'Ruangan Aktif'
        
        # Set required fields
        self.fields['name'].required = True
        self.fields['capacity'].required = True
        self.fields['location'].required = True
        self.fields['description'].required = False
        self.fields['facilities'].required = False
        self.fields['image'].required = False

class BookingForm(forms.ModelForm):
    class Meta:
        model = Booking
        fields = ['room', 'title', 'description', 'start_datetime', 'end_datetime', 'participants']
        widgets = {
            'start_datetime': DateTimePickerInput(
                options={
                    "format": "DD/MM/YYYY HH:mm",
                    "showClose": True,
                    "showClear": True,
                    "showTodayButton": True,
                }
            ),
            'end_datetime': DateTimePickerInput(
                options={
                    "format": "DD/MM/YYYY HH:mm",
                    "showClose": True,
                    "showClear": True,
                    "showTodayButton": True,
                }
            ),
            'description': forms.Textarea(attrs={'rows': 3}),
        }

    def __init__(self, *args, **kwargs):
        user = kwargs.pop('user', None)
        super().__init__(*args, **kwargs)
        
        # Filter hanya ruangan yang aktif
        self.fields['room'].queryset = Room.objects.filter(is_active=True)
        
        self.helper = FormHelper()
        self.helper.layout = Layout(
            'room',
            'title',
            'description',
            Row(
                Column('start_datetime', css_class='form-group col-md-6 mb-0'),
                Column('end_datetime', css_class='form-group col-md-6 mb-0'),
                css_class='form-row'
            ),
            'participants',
            Submit('submit', 'Buat Booking', css_class='btn btn-primary')
        )

    def clean(self):
        cleaned_data = super().clean()
        start_datetime = cleaned_data.get('start_datetime')
        end_datetime = cleaned_data.get('end_datetime')
        room = cleaned_data.get('room')
        participants = cleaned_data.get('participants')

        if start_datetime and end_datetime:
            if start_datetime >= end_datetime:
                raise forms.ValidationError("Waktu mulai harus sebelum waktu selesai.")

        if room and participants:
            if participants > room.capacity:
                raise forms.ValidationError(
                    f"Jumlah peserta ({participants}) melebihi kapasitas ruangan ({room.capacity})."
                )

        return cleaned_data

class BookingUpdateForm(forms.ModelForm):
    class Meta:
        model = Booking
        fields = ['title', 'description', 'start_datetime', 'end_datetime', 'participants']
        widgets = {
            'start_datetime': DateTimePickerInput(
                options={
                    "format": "DD/MM/YYYY HH:mm",
                    "showClose": True,
                    "showClear": True,
                    "showTodayButton": True,
                }
            ),
            'end_datetime': DateTimePickerInput(
                options={
                    "format": "DD/MM/YYYY HH:mm",
                    "showClose": True,
                    "showClear": True,
                    "showTodayButton": True,
                }
            ),
            'description': forms.Textarea(attrs={'rows': 3}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.helper = FormHelper()
        self.helper.layout = Layout(
            'title',
            'description',
            Row(
                Column('start_datetime', css_class='form-group col-md-6 mb-0'),
                Column('end_datetime', css_class='form-group col-md-6 mb-0'),
                css_class='form-row'
            ),
            'participants',
            Submit('submit', 'Update Booking', css_class='btn btn-primary')
        )

class BookingStatusForm(forms.ModelForm):
    class Meta:
        model = Booking
        fields = ['status', 'notes']
        widgets = {
            'notes': forms.Textarea(attrs={'rows': 3}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.helper = FormHelper()
        self.helper.layout = Layout(
            'status',
            'notes',
            Submit('submit', 'Update Status', css_class='btn btn-warning')
        )
