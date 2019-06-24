import React from 'react';
import { SelectInput, Create, Edit, SimpleForm, DisabledInput, TextInput, DateInput, LongTextInput, ReferenceManyField, Datagrid, TextField, DateField, EditButton } from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

export const PostCreate = (props) => (
    <Create {...props}>
        <SimpleForm>
            <TextInput source="title" />
            <SelectInput source="dropdown" choices={[{ id: 'M', name: 'Male' }, { id: 'F', name: 'Female' }]} />
        </SimpleForm>
    </Create>
);