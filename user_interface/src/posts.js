import React from 'react';
import { SelectInput, Create, SimpleForm, TextInput } from 'react-admin';

export const PostCreate = (props) => (
    <Create {...props}>
        <SimpleForm>
            <TextInput source="title" />
            <SelectInput source="dropdown" choices={[{ id: 'M', name: 'Male' }, { id: 'F', name: 'Female' }]} />
        </SimpleForm>
    </Create>
);