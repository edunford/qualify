import React from 'react';
import { SelectInput, Create, TextInput, TabbedForm, FormTab, ListGuesser } from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

export const PostCreate = (props) => (
    <Create {...props}>
        <TabbedForm>
            <FormTab label="Coding">
                <TextInput source="title" />
                <SelectInput source="dropdown" choices={[{ id: 'M', name: 'Male' }, { id: 'F', name: 'Female' }]} />
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Create>
);