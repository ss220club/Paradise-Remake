import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Stack, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Photocopier = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={400} height={440}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Section title="Photocopier" color="silver">
            <LabeledList>
              <LabeledList.Item label="Copies">
                <Stack>
                  <Box width="2em" bold>
                    {data.copynumber}
                  </Box>
                  <Fragment float="right">
                    <Button
                      fluid
                      icon="minus"
                      textAlign="center"
                      content=""
                      onClick={() => act('minus')}
                    />
                    <Button
                      fluid
                      icon="plus"
                      textAlign="center"
                      content=""
                      onClick={() => act('add')}
                    />
                  </Fragment>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Toner">
                <Box bold>{data.toner}</Box>
              </LabeledList.Item>
              <LabeledList.Item label="Inserted Document">
                <Button
                  fluid
                  textAlign="center"
                  disabled={!data.copyitem && !data.mob}
                  content={
                    data.copyitem
                      ? data.copyitem
                      : data.mob
                        ? data.mob + "'s ass!"
                        : 'document'
                  }
                  onClick={() => act('removedocument')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Inserted Folder">
                <Button
                  fluid
                  textAlign="center"
                  disabled={!data.folder}
                  content={data.folder ? data.folder : 'folder'}
                  onClick={() => act('removefolder')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section>
            <Actions />
          </Section>
          <Files />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Actions = (props, context) => {
  const { act, data } = useBackend(context);
  const { issilicon } = data;
  return (
    <>
      <Button
        fluid
        icon="copy"
        float="center"
        textAlign="center"
        content="Copy"
        onClick={() => act('copy')}
      />
      <Button
        fluid
        icon="file-import"
        float="center"
        textAlign="center"
        content="Scan"
        onClick={() => act('scandocument')}
      />
      {!!issilicon && (
        <>
          <Button
            fluid
            icon="file"
            color="green"
            float="center"
            textAlign="center"
            content="Print Text"
            onClick={() => act('ai_text')}
          />
          <Button
            fluid
            icon="image"
            color="green"
            float="center"
            textAlign="center"
            content="Print Image"
            onClick={() => act('ai_pic')}
          />
        </>
      )}
    </>
  );
};

const Files = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section fill scrollable title="Scanned Files">
      {data.files.map((file) => (
        <Section
          key={file.name}
          title={file.name}
          buttons={
            <Stack>
              <Button
                icon="print"
                content="Print"
                disabled={data.toner <= 0}
                onClick={() =>
                  act('filecopy', {
                    uid: file.uid,
                  })
                }
              />
              <Button.Confirm
                icon="trash-alt"
                content="Delete"
                color="bad"
                onClick={() =>
                  act('deletefile', {
                    uid: file.uid,
                  })
                }
              />
            </Stack>
          }
        />
      ))}
    </Section>
  );
};
