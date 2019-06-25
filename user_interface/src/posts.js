import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput } from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const PostTitle = ({ record }) => {
    return <span>Post {record ? `"${record.title}"` : ''}</span>;
};

const Header = () => {
    return <hr></hr>;
}

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
                <TextInput source="evidence" />
                <DateInput source="publication_date" />
                <Header />
                <SelectInput source="code" choices={[{ id: 'M', name: 'Male' }, { id: 'F', name: 'Female' }]} />
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
