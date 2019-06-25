import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab } from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const PostTitle = ({ record }) => {
    return <span>Post {record ? `"${record.title}"` : ''}</span>;
};

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
                <TextInput source="title" />
                <SelectInput source="dropdown" choices={[{ id: 'M', name: 'Male' }, { id: 'F', name: 'Female' }]} />
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);